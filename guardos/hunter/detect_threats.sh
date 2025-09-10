#!/usr/bin/env bash
# GuardOS — Hunter: Threat Detector (pre‑alpha)
# Purpose: Scan system logs with conservative heuristics and output a concise report.
# - Local‑only, no network calls.
# - Safe-by-default: read‑only, regex-based, no PII leakage in output.
# - Works without external deps (awk/grep/sed only).
#
# USAGE:
#   bash guardos/hunter/detect_threats.sh [--json] [--since '2025-09-01'] [--limit 2000] <log_glob...>
#
# EXAMPLES:
#   bash guardos/hunter/detect_threats.sh /var/log/auth.log /var/log/syslog
#   bash guardos/hunter/detect_threats.sh --json "/var/log/*.log"
#
# EXIT CODES:
#   0 = ran successfully (issues may still be found)
#   1 = usage error
#   2 = no logs found

set -euo pipefail

EMIT_JSON=false
SINCE=""
LIMIT=5000

args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)  EMIT_JSON=true; shift ;;
    --since) SINCE="${2:-}"; [[ -n "$SINCE" ]] || { echo "Missing value for --since" >&2; exit 1; }; shift 2 ;;
    --limit) LIMIT="${2:-}"; [[ "$LIMIT" =~ ^[0-9]+$ ]] || { echo "--limit must be integer" >&2; exit 1; }; shift 2 ;;
    -h|--help)
      sed -n '1,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) args+=("$1"); shift ;;
  esac
done

if [[ ${#args[@]} -eq 0 ]]; then
  echo "Usage: $(basename "$0") [--json] [--since 'YYYY-MM-DD'] [--limit N] <log_glob...>" >&2
  exit 1
fi

# Expand globs safely
shopt -s nullglob
logs=()
for g in "${args[@]}"; do
  for f in $g; do
    [[ -f "$f" ]] && logs+=("$f")
  done
done
shopt -u nullglob

if [[ ${#logs[@]} -eq 0 ]]; then
  echo "No matching log files." >&2
  exit 2
fi

# ----- Helpers -----
redact() {
  # Minimal PII/secrets redaction for output safety
  sed -E '
    s/([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})/[redacted-email]/g;
    s/([0-9]{1,3}\.){3}[0-9]{1,3}/[redacted-ip]/g;
    s/([0-9A-Fa-f:]{2,}:){2,}[0-9A-Fa-f]{1,}/[redacted-mac-or-ipv6]/g;
    s/(password|passwd|secret|token|apikey)[^[:alnum:]]+[^\ ]+/\1=[redacted]/gi;
    s/(-----BEGIN [A-Z ]+PRIVATE KEY-----)[\s\S]+?(-----END [A-Z ]+PRIVATE KEY-----)/\1[REDACTED]\2/g;
  '
}

ts_filter() {
  # If --since is set, try to filter lines with a loose date matcher.
  # This is heuristic and log-format dependent; if it fails, we pass all lines.
  if [[ -z "$SINCE" ]]; then cat
  else
    awk -v SINCE="$SINCE" '
      BEGIN {
        # Convert SINCE to seconds since epoch if possible (YYYY-MM-DD)
        split(SINCE, d, "-");
        if (length(d[1])==4) {
          since_epoch = mktime(sprintf("%s %s %s 00 00 00", d[1], d[2], d[3]));
        } else {
          since_epoch = 0;
        }
      }
      function maybe_epoch(line,  y,m,day,H,M,S,t,ok) {
        # Try common formats: "YYYY-MM-DD", "MMM DD", etc. Very conservative.
        if (match(line, /([0-9]{4})-([0-9]{2})-([0-9]{2})[ T]([0-9]{2}):([0-9]{2}):([0-9]{2})/, t)) {
          y=t[1]; m=t[2]; day=t[3]; H=t[4]; M=t[5]; S=t[6];
          return mktime(sprintf("%s %s %s %s %s %s", y,m,day,H,M,S));
        }
        return 0; # unknown
      }
      {
        e = maybe_epoch($0);
        if (since_epoch==0 || e==0 || e>=since_epoch) print $0;
      }
    '
  fi
}

tail_limit() {
  # Limit total lines processed to avoid heavy scans on huge logs
  awk -v L="$LIMIT" 'NR<=L'
}

# ----- Heuristics -----
# Conservative patterns: auth failures, sudo misuse, kernel oops, segfaults, suspicious execs
# You will grow these over time and profile-specific rules can add/ignore patterns.

patterns=(
  # Auth & sudo
  "Failed password for"
  "authentication failure"
  "sudo: .*command not allowed"
  "invalid user .* from"
  "PAM .* authentication failure"
  # SSH anomalies
  "sshd\[.*\]: error:"
  "sshd\[.*\]: Disconnecting:"
  "reverse mapping checking getaddrinfo"
  # Kernel and system
  "kernel:.*BUG:"
  "kernel:.*segfault"
  "kernel:.*oops"
  "audit:.*AVC.*denied"
  # Suspicious exec & persistence hints
  "cron\[[0-9]+\]: .* CMD=.*(curl|wget|nc|bash -c|sh -c)"
  "systemd\[.*\]: .*Failed to start"
  # Package / supply chain (basic)
  "dpkg: error"
  "pacman: error"
  "signature.*(invalid|expired)"
)

ignore_patterns=(
  # Common benign noise (tune carefully)
  "Failed password for invalid user root from 127\.0\.0\.1"
  "reverse mapping checking getaddrinfo for localhost"
  "systemd: Started .* (Daily|Hourly) .* timer"
)

matches=()
scan_file() {
  local f="$1"
  local n=0
  # Pre-filter lines
  while IFS= read -r line; do
    # Basic ignore
    skip=false
    for ip in "${ignore_patterns[@]}"; do
      if [[ "$line" =~ $ip ]]; then skip=true; break; fi
    done
    $skip && continue
    # Check interesting patterns
    for p in "${patterns[@]}"; do
      if [[ "$line" =~ $p ]]; then
        n=$((n+1))
        # Redact and store limited context
        safe="$(printf "%s" "$line" | redact)"
        matches+=("$f|$safe")
        break
      fi
    done
  done < <(cat "$f" | ts_filter | tail_limit)
  echo "$n"
}

total=0
declare -A per_file
for f in "${logs[@]}"; do
  c="$(scan_file "$f")"
  per_file["$f"]="$c"
  total=$((total + c))
done

# ----- Output -----
if $EMIT_JSON; then
  # Minimal JSON (no special escaping beyond basic); safe since we redacted.
  echo -n '{"summary":{"files":['
  i=0
  for f in "${!per_file[@]}"; do
    [[ $i -gt 0 ]] && echo -n ','
    echo -n "{\"file\":\"$(printf "%s" "$f")\",\"hits\":${per_file[$f]}}"
    i=$((i+1))
  done
  echo -n "],\"total_hits\":$total},\"findings\":["
  for j in "${!matches[@]}"; do
    [[ $j -gt 0 ]] && echo -n ','
    file="${matches[$j]%%|*}"
    line="${matches[$j]#*|}"
    # Trim overly long lines
    short="$(printf "%.400s" "$line")"
    echo -n "{\"file\":\"$(printf "%s" "$file")\",\"line\":\"$(printf "%s" "$short")\"}"
  done
  echo "]}"
else
  echo "Hunter — Threat Detector Report"
  echo "--------------------------------"
  for f in "${logs[@]}"; do
    printf "  %-50s  hits: %s\n" "$f" "${per_file[$f]}"
  done
  echo "--------------------------------"
  echo "Total suspicious hits: $total"
  echo
  if [[ $total -gt 0 ]]; then
    echo "Findings (redacted):"
    for m in "${matches[@]}"; do
      file="${m%%|*}"
      line="${m#*|}"
      printf "  [%s] %s\n" "$file" "$line"
    done
  else
    echo "No suspicious patterns found (with current heuristics)."
  fi
fi

exit 0
