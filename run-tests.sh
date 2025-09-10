#!/usr/bin/env bash
# GuardOS — Quick Test Suite (pre‑alpha)
# Runs a battery of smoke tests against the shell prototype:
#  - layout checks
#  - profile validation
#  - guardpanel CLI tools
#  - hunter threat scan (with sample data)
#  - boot simulation
#
# USAGE:
#   bash run-tests.sh [--profile profiles/dev-test.yaml]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="$REPO_ROOT/profiles/minimal.yaml"
TESTDIR="$REPO_ROOT/.guardos/tests"
LOGDIR="$TESTDIR/logs"
OUTDIR="$TESTDIR/out"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2;;
    -h|--help)
      sed -n '1,40p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

say(){ echo -e "\n==> $*"; }
ok(){ echo "   ✓ $*"; }
fail(){ echo "   ✗ $*"; exit 1; }

# --------- Prep ---------
mkdir -p "$LOGDIR" "$OUTDIR"

# Create small sample files
echo "Test email: test@example.com  IP: 192.168.1.20  KEY: -----BEGIN PRIVATE KEY----- ZZZ -----END PRIVATE KEY-----" > "$OUTDIR/sample.txt"
cat > "$LOGDIR/auth.log" <<'EOF'
2025-01-01 10:00:00 auth sshd[1234]: Failed password for invalid user root from 203.0.113.5 port 443
2025-01-01 10:01:00 auth sshd[1234]: reverse mapping checking getaddrinfo for localhost failed - POSSIBLY SAFE
2025-01-01 10:02:00 sudo: operator : command not allowed ; TTY=pts/0 ; PWD=/home/operator ; USER=root ; COMMAND=/bin/cat /etc/shadow
EOF

# --------- 1) Layout checks ---------
say "Checking expected files"
for p in \
  "$REPO_ROOT/guardos/guardpanel/cli.sh" \
  "$REPO_ROOT/guardos/aegis/validate_config.sh" \
  "$REPO_ROOT/guardos/hunter/detect_threats.sh" \
  "$REPO_ROOT/guardos/system/boot_init.sh" \
  "$REPO_ROOT/ai/policies/safety.yaml" \
  "$REPO_ROOT/ai/policies/tool_rules.yaml" \
  "$REPO_ROOT/ai/prompts/guardpanel/base.md" \
  "$REPO_ROOT/profiles/minimal.yaml"; do
  [[ -e "$p" ]] || fail "Missing: $p"
done
ok "Repo layout OK"

# --------- 2) Profile validation ---------
say "Validating profile: $PROFILE"
bash "$REPO_ROOT/guardos/aegis/validate_config.sh" "$PROFILE" || { code=$?; fail "Profile invalid (exit $code)"; }
ok "Profile valid"

# --------- 3) GuardPanel: show-config ---------
say "GuardPanel show-config"
bash "$REPO_ROOT/guardos/guardpanel/cli.sh" show-config >/dev/null
ok "GuardPanel show-config OK"

# --------- 4) GuardPanel: read-file (redaction) ---------
say "GuardPanel read-file (with redaction)"
out="$("$REPO_ROOT/guardos/guardpanel/cli.sh" read-file "$OUTDIR/sample.txt")"
echo "$out" | grep -q "\[redacted-email\]" || fail "Email not redacted"
echo "$out" | grep -q "\[redacted-ip\]" || fail "IP not redacted"
echo "$out" | grep -q "BEGIN .* PRIVATE KEY" || fail "Key markers not preserved"
echo "$out" | grep -q "\[REDACTED\]" || fail "Key body not redacted"
ok "Redaction working"

# --------- 5) GuardPanel: hash-file ---------
say "GuardPanel hash-file"
hash="$("$REPO_ROOT/guardos/guardpanel/cli.sh" hash-file "$OUTDIR/sample.txt")"
[[ ${#hash} -ge 64 ]] || fail "Hash too short"
ok "Hash produced: $hash"

# --------- 6) Hunter: detect threats (JSON + CLI) ---------
say "Hunter detect_threats (CLI)"
bash "$REPO_ROOT/guardos/hunter/detect_threats.sh" "$LOGDIR/*.log" | sed -n '1,5p'
ok "Hunter CLI scan ran"

say "Hunter detect_threats (JSON)"
json="$("$REPO_ROOT/guardos/hunter/detect_threats.sh" --json "$LOGDIR/*.log")"
echo "$json" | grep -q '"total_hits":' || fail "JSON summary missing"
ok "Hunter JSON scan OK"

# --------- 7) Boot simulation ---------
say "Boot simulation"
bash "$REPO_ROOT/guardos/system/boot_init.sh" "$PROFILE" >/dev/null
ok "Boot simulation OK"

# --------- 8) Packaging (optional quick check) ---------
say "Packaging dry-run"
bash "$REPO_ROOT/build.sh" package
[[ -d "$REPO_ROOT/dist" ]] || fail "dist/ not created"
ls -1 "$REPO_ROOT/dist"/GuardOS-prealpha-*.tar.gz >/dev/null 2>&1 || fail "No tarball produced"
ok "Packaging OK"

say "All tests passed."
