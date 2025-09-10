#!/usr/bin/env bash
# GuardOS — Aegis Config Validator (pre‑alpha)
# Purpose: Validate GuardOS profiles and AI policy wiring before boot.
# - Works without external deps (no yq/jq). Uses awk/grep/sed only.
# - Checks: basic YAML keys, modes, booleans, file paths, policies existence.
# - Outputs a human summary and a machine‑readable verdict line.
#
# USAGE:
#   bash guardos/aegis/validate_config.sh [--strict] [--json] <profile.yaml>
#
# EXIT CODES:
#   0 = valid (no errors)
#   2 = warnings only
#   3 = errors found
#
# NOTES:
#   This is a defensive linter. It does not “execute” configs; it just checks structure
#   and presence of referenced files inside the repo workspace when applicable.

set -euo pipefail

# ---------------- Config ----------------
STRICT=false
EMIT_JSON=false

# ---------------- Args ------------------
if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") [--strict] [--json] <profile.yaml>" >&2
  exit 3
fi

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=true; shift;;
    --json)   EMIT_JSON=true; shift;;
    *)        ARGS+=("$1"); shift;;
  esac
done

PROFILE_FILE="${ARGS[0]:-}"
[[ -f "$PROFILE_FILE" ]] || { echo "Error: Profile not found: $PROFILE_FILE" >&2; exit 3; }

# ---------------- Helpers ----------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AI_POL_SAF_DEF="$REPO_ROOT/ai/policies/safety.yaml"
AI_POL_TOL_DEF="$REPO_ROOT/ai/policies/tool_rules.yaml"
PROMPT_DEF="$REPO_ROOT/ai/prompts/guardpanel/base.md"

warns=()
errors=()

add_warn(){ warns+=("$*"); }
add_err(){  errors+=("$*"); }

trim(){ sed -E 's/^[[:space:]]+|[[:space:]]+$//g'; }

yaml_scalar() {
  # $1=file $2=key (supports section.key one level)
  local file="$1" key="$2"
  if [[ "$key" == *.* ]]; then
    local section="${key%%.*}"
    local subkey="${key##*.}"
    awk -v sec="^${section}:" -v k="^[[:space:]]*${subkey}:" '
      BEGIN{insec=0}
      $0 ~ sec {insec=1; next}
      insec && /^[^[:space:]]/ {insec=0}
      insec && $0 ~ k {
        sub(/^[^:]*:[[:space:]]*/, "", $0)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0; exit
      }
    ' "$file"
  else
    awk -v k="^${key}:" '
      $0 ~ k {
        sub(/^[^:]*:[[:space:]]*/, "", $0)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0; exit
      }
    ' "$file"
  fi
}

yaml_bool() {
  local v; v="$(yaml_scalar "$1" "$2" | tr '[:upper:]' '[:lower:]')"
  case "$v" in
    true|false) echo "$v";;
    *) echo "";;
  esac
}

exists_or_warn() {
  local path="$1" label="$2"
  if [[ -z "$path" ]]; then
    add_warn "$label is empty"
    return 1
  fi
  if [[ ! -e "$path" ]]; then
    add_warn "$label not found: $path"
    return 1
  fi
  return 0
}

exists_or_err() {
  local path="$1" label="$2"
  if [[ -z "$path" ]]; then
    add_err "$label is empty"
    return 1
  fi
  if [[ ! -e "$path" ]]; then
    add_err "$label not found: $path"
    return 1
  fi
  return 0
}

# ---------------- Extract Fields ----------------
PROFILE_ID="$(yaml_scalar "$PROFILE_FILE" "profile_id")"
DESCRIPTION="$(yaml_scalar "$PROFILE_FILE" "description")"

HOSTNAME="$(yaml_scalar "$PROFILE_FILE" "system.hostname")"
TIMEZONE="$(yaml_scalar "$PROFILE_FILE" "system.timezone")"
LOCALE="$(yaml_scalar "$PROFILE_FILE" "system.locale")"

NET_ENABLED="$(yaml_bool "$PROFILE_FILE" "network.enabled")"

AI_ENABLED="$(yaml_bool "$PROFILE_FILE" "ai.enabled")"
AI_MODE="$(yaml_scalar "$PROFILE_FILE" "ai.mode" | tr '[:upper:]' '[:lower:]')"
AI_MODEL_ID="$(yaml_scalar "$PROFILE_FILE" "ai.model_id")"
AI_RUNTIME="$(yaml_scalar "$PROFILE_FILE" "ai.runtime")"
AI_CONSENT="$(yaml_bool "$PROFILE_FILE" "ai.consent_required")"

POL_SAF="$(yaml_scalar "$PROFILE_FILE" "ai.policies.safety")"
POL_TOL="$(yaml_scalar "$PROFILE_FILE" "ai.policies.tools")"
LOG_ROTATE="$(yaml_scalar "$PROFILE_FILE" "ai.logging.rotate_days")"

TP_RUN="$(yaml_bool "$PROFILE_FILE" "tools.run_command")"
TP_READ="$(yaml_bool "$PROFILE_FILE" "tools.read_file")"
TP_WRITE="$(yaml_bool "$PROFILE_FILE" "tools.write_file")"
TP_LOGS="$(yaml_bool "$PROFILE_FILE" "tools.search_logs")"
TP_HASH="$(yaml_bool "$PROFILE_FILE" "tools.hash_file")"

GP_ENABLED="$(yaml_bool "$PROFILE_FILE" "guardpanel.enabled")"
GP_PROMPT="$(yaml_scalar "$PROFILE_FILE" "guardpanel.prompt")"

# ---------------- Validations ----------------

# Basic identity
[[ -n "$PROFILE_ID" ]] || add_err "profile_id missing"
[[ -n "$DESCRIPTION" ]] || add_warn "description missing"

# System
[[ -n "$HOSTNAME" ]] || add_warn "system.hostname missing"
[[ -n "$TIMEZONE" ]] || add_warn "system.timezone missing"
[[ -n "$LOCALE" ]]   || add_warn "system.locale missing"

# Network vs modes (Local‑Only allows network=false; if true, still AI can be local)
if [[ "$NET_ENABLED" == "" ]]; then add_warn "network.enabled missing (assume false)"; fi

# AI block
if [[ "$AI_ENABLED" != "true" && "$AI_ENABLED" != "false" ]]; then
  add_err "ai.enabled must be true/false"
fi

if [[ "$AI_ENABLED" == "true" ]]; then
  case "$AI_MODE" in
    local|hybrid|cloud) : ;;
    *) add_err "ai.mode must be one of: local|hybrid|cloud";;
  esac

  [[ -n "$AI_MODEL_ID" ]] || add_err "ai.model_id missing"
  [[ -n "$AI_RUNTIME"  ]] || add_warn "ai.runtime missing (will default to local runtime)"
  if [[ "$AI_CONSENT" == "" ]]; then add_warn "ai.consent_required missing (recommended: true)"; fi

  # Policies must exist relative to repo root if they look like repo paths
  POL_SAF_ABS="$POL_SAF"
  POL_TOL_ABS="$POL_TOL"
  [[ "$POL_SAF_ABS" != /* ]] && POL_SAF_ABS="$REPO_ROOT/$POL_SAF"
  [[ "$POL_TOL_ABS" != /* ]] && POL_TOL_ABS="$REPO_ROOT/$POL_TOL"

  if ! exists_or_err "$POL_SAF_ABS" "ai.policies.safety"; then :; fi
  if ! exists_or_err "$POL_TOL_ABS" "ai.policies.tools"; then :; fi

  # GuardPanel prompt
  GP_PROMPT_ABS="$GP_PROMPT"
  [[ "$GP_PROMPT_ABS" != /* ]] && GP_PROMPT_ABS="$REPO_ROOT/$GP_PROMPT"
  if [[ "$GP_ENABLED" == "true" ]]; then
    exists_or_err "$GP_PROMPT_ABS" "guardpanel.prompt" || :
  fi
fi

# Tools sanity: if run_command enabled, consent should be true
if [[ "$TP_RUN" == "true" && "$AI_CONSENT" != "true" ]]; then
  add_warn "tools.run_command=true but ai.consent_required!=true (recommend enabling consent)"
fi

# Logging
if [[ -n "$LOG_ROTATE" ]]; then
  if ! [[ "$LOG_ROTATE" =~ ^[0-9]+$ ]]; then
    add_warn "ai.logging.rotate_days is not an integer: $LOG_ROTATE"
  fi
fi

# Resolve defaults if missing (informational)
[[ -z "$POL_SAF" ]] && POL_SAF="$AI_POL_SAF_DEF"
[[ -z "$POL_TOL" ]] && POL_TOL="$AI_POL_TOL_DEF"
[[ -z "$GP_PROMPT" ]] && GP_PROMPT="$PROMPT_DEF"

# ---------------- Report ----------------
echo "GuardOS Aegis — Profile Validation"
echo "----------------------------------"
echo "Profile:       $PROFILE_FILE"
echo "profile_id:    ${PROFILE_ID:-<missing>}"
echo "description:   ${DESCRIPTION:-<missing>}"
echo
echo "System:"
echo "  hostname:    ${HOSTNAME:-<missing>}"
echo "  timezone:    ${TIMEZONE:-<missing>}"
echo "  locale:      ${LOCALE:-<missing>}"
echo "Network:"
echo "  enabled:     ${NET_ENABLED:-<unset>}"
echo
echo "AI:"
echo "  enabled:           ${AI_ENABLED:-<missing>}"
echo "  mode:              ${AI_MODE:-<missing>}"
echo "  model_id:          ${AI_MODEL_ID:-<missing>}"
echo "  runtime:           ${AI_RUNTIME:-<missing>}"
echo "  consent_required:  ${AI_CONSENT:-<missing>}"
echo "  policies:"
echo "    safety:          ${POL_SAF:-<missing>}"
echo "    tools:           ${POL_TOL:-<missing>}"
echo "GuardPanel:"
echo "  enabled:           ${GP_ENABLED:-<missing>}"
echo "  prompt:            ${GP_PROMPT:-<missing>}"
echo
echo "Tools:"
printf "  run_command: %s | read_file: %s | write_file: %s | search_logs: %s | hash_file: %s\n" \
  "${TP_RUN:-<unset>}" "${TP_READ:-<unset>}" "${TP_WRITE:-<unset>}" "${TP_LOGS:-<unset>}" "${TP_HASH:-<unset>}"
echo

if [[ ${#warns[@]} -gt 0 ]]; then
  echo "WARNINGS:"
  for w in "${warns[@]}"; do echo "  - $w"; done
  echo
fi

if [[ ${#errors[@]} -gt 0 ]]; then
  echo "ERRORS:"
  for e in "${errors[@]}"; do echo "  - $e"; done
  verdict="invalid"
  code=3
else
  verdict=$([[ ${#warns[@]} -gt 0 ]] && echo "valid-with-warnings" || echo "valid")
  code=$([[ ${#warns[@]} -gt 0 ]] && echo 2 || echo 0)
fi

if $EMIT_JSON; then
  # Minimal JSON (no external jq). Escape not handled for exotic chars in messages.
  echo "{\"profile\":\"$PROFILE_FILE\",\"verdict\":\"$verdict\",\"warnings\":${#warns[@]},\"errors\":${#errors[@]}}"
else
  echo "VERDICT: $verdict"
fi

exit "$code"
