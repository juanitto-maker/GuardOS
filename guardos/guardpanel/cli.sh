#!/usr/bin/env bash
# GuardOS — GuardPanel CLI (pre‑alpha)
# Purpose: Local, policy‑aware command‑line assistant stub.
# - Loads repo policies & a selected profile
# - Enforces Local‑Only defaults (no network, consent before risky tools)
# - Provides safe utilities (read_file, list_dir, hash_file, summarize_file*)
# - Prepares a single place to wire a local LLM runtime when available
#
# (*) summarize_file currently uses a simple built‑in heuristic.
#     Replace with a local LLM call by implementing ai_infer() below.

set -euo pipefail

# -------------- Paths & Defaults --------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ENV_LOCAL="${REPO_ROOT}/.env"
ENV_USER="${HOME}/.guardos/ai.env"

PROFILE_FILE_DEFAULT="${REPO_ROOT}/profiles/minimal.yaml"
POLICY_SAFETY_DEFAULT="${REPO_ROOT}/ai/policies/safety.yaml"
POLICY_TOOLS_DEFAULT="${REPO_ROOT}/ai/policies/tool_rules.yaml"
PROMPT_GUARDPANEL_DEFAULT="${REPO_ROOT}/ai/prompts/guardpanel/base.md"

LOG_DIR_DEFAULT="${REPO_ROOT}/.guardos/logs"
LOG_ROTATE_DAYS_DEFAULT="14"
LOG_LEVEL_DEFAULT="info"

# -------------- Helpers --------------

log() {
  local level="$1"; shift
  local msg="$*"
  local now; now="$(date +"%Y-%m-%d %H:%M:%S")"
  case "$LOG_LEVEL" in
    debug) echo "[$now] [$level] $msg" ;;
    info)  [[ "$level" =~ ^(info|warn|error)$ ]] && echo "[$now] [$level] $msg" ;;
    warn)  [[ "$level" =~ ^(warn|error)$ ]] && echo "[$now] [$level] $msg" ;;
    error) [[ "$level" == "error" ]] && echo "[$now] [$level] $msg" ;;
    *)     [[ "$level" =~ ^(info|warn|error)$ ]] && echo "[$now] [$level] $msg" ;;
  esac
}

die() { log error "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

# graceful optional deps
have_cmd() { command -v "$1" >/dev/null 2>&1; }

mkdir_p() { mkdir -p "$1" 2>/dev/null || true; }

# -------------- Env / Profile Loading --------------

# Load env in this priority: ./.env -> ~/.guardos/ai.env
[[ -f "$ENV_LOCAL" ]] && source "$ENV_LOCAL"
[[ -f "$ENV_USER"  ]] && source "$ENV_USER"

# Defaults if unset
GUARDOS_AI_MODE="${GUARDOS_AI_MODE:-local}"           # local | hybrid | cloud
GUARDOS_AI_RUNTIME="${GUARDOS_AI_RUNTIME:-llama.cpp}" # placeholder name
GUARDOS_MODEL_ID="${GUARDOS_MODEL_ID:-gemma-0.27b-q4km}"
GUARDOS_MODEL_PATH="${GUARDOS_MODEL_PATH:-}"
GUARDOS_MAX_TOKENS="${GUARDOS_MAX_TOKENS:-256}"
GUARDOS_TEMP="${GUARDOS_TEMP:-0.7}"
GUARDOS_TOP_P="${GUARDOS_TOP_P:-0.95}"

GUARDOS_POLICY_SAFETY="${GUARDOS_POLICY_SAFETY:-$POLICY_SAFETY_DEFAULT}"
GUARDOS_POLICY_TOOLS="${GUARDOS_POLICY_TOOLS:-$POLICY_TOOLS_DEFAULT}"
GUARDOS_PROMPT_GUARDPANEL="${GUARDOS_PROMPT_GUARDPANEL:-$PROMPT_GUARDPANEL_DEFAULT}"

GUARDOS_LOG_DIR="${GUARDOS_LOG_DIR:-$LOG_DIR_DEFAULT}"
GUARDOS_LOG_ROTATE_DAYS="${GUARDOS_LOG_ROTATE_DAYS:-$LOG_ROTATE_DAYS_DEFAULT}"
LOG_LEVEL="${GUARDOS_LOG_LEVEL:-$LOG_LEVEL_DEFAULT}"

GUARDOS_PROFILE="${GUARDOS_PROFILE:-$PROFILE_FILE_DEFAULT}"
GUARDOS_REQUIRE_CONSENT="${GUARDOS_REQUIRE_CONSENT:-true}"

mkdir_p "$GUARDOS_LOG_DIR"

# -------------- Minimal YAML parsing (no external deps) --------------
# NOTE: We avoid strict YAML parsing to keep the CLI portable. These helpers
#       read simple "key: value" pairs from known files. For complex YAML,
#       prefer yq if available.

yaml_get_scalar() {
  # $1=file $2=key (e.g. ai.mode)
  local file="$1" key="$2"
  # Simplistic: supports up to one nested level (section.key)
  if [[ "$key" == *.* ]]; then
    local section="${key%%.*}"
    local subkey="${key##*.}"
    # Extract section block lines, then find key
    awk -v sec="^${section}:" -v k="^[[:space:]]*${subkey}:" '
      BEGIN{insec=0}
      $0 ~ sec {insec=1; next}
      insec && /^[^[:space:]]/ {insec=0}
      insec {
        if ($0 ~ k) {
          # split on ":" and trim
          sub(/^[^:]*:[[:space:]]*/, "", $0)
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
          print $0; exit
        }
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

profile_read() {
  local key="$1"
  yaml_get_scalar "$GUARDOS_PROFILE" "$key"
}

# Load some profile values (fallback to env/defaults)
PROFILE_AI_MODE="$(profile_read "ai.mode" || true)"
[[ -n "${PROFILE_AI_MODE:-}" ]] && GUARDOS_AI_MODE="$PROFILE_AI_MODE"

PROFILE_MODEL_ID="$(profile_read "ai.model_id" || true)"
[[ -n "${PROFILE_MODEL_ID:-}" ]] && GUARDOS_MODEL_ID="$PROFILE_MODEL_ID"

PROFILE_CONSENT="$(profile_read "ai.consent_required" || true)"
[[ -n "${PROFILE_CONSENT:-}" ]] && GUARDOS_REQUIRE_CONSENT="$PROFILE_CONSENT"

# Tools from profile (basic booleans)
PROFILE_TOOL_RUN_COMMAND="$(profile_read "tools.run_command" || true)"
PROFILE_TOOL_READ_FILE="$(profile_read "tools.read_file" || true)"
PROFILE_TOOL_WRITE_FILE="$(profile_read "tools.write_file" || true)"
PROFILE_TOOL_SEARCH_LOGS="$(profile_read "tools.search_logs" || true)"
PROFILE_TOOL_HASH_FILE="$(profile_read "tools.hash_file" || true)"

# -------------- Policy Enforcement Stubs --------------

require_consent() {
  local prompt="$1"
  if [[ "${GUARDOS_REQUIRE_CONSENT,,}" != "true" ]]; then
    return 0
  fi
  echo
  echo ">>> CONSENT REQUIRED:"
  echo "$prompt"
  echo -n "Proceed? [y/N]: "
  read -r ans
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

assert_mode_local_network_denied() {
  if [[ "$GUARDOS_AI_MODE" == "local" ]]; then
    die "Network operations are disabled in Local‑Only mode."
  fi
}

enforce_tool_allowed() {
  local tool="$1"
  local allowed="false"
  case "$tool" in
    run_command)  [[ "${PROFILE_TOOL_RUN_COMMAND,,}"  == "true" ]] && allowed="true" ;;
    read_file)    [[ "${PROFILE_TOOL_READ_FILE,,}"    == "true" ]] && allowed="true" ;;
    write_file)   [[ "${PROFILE_TOOL_WRITE_FILE,,}"   == "true" ]] && allowed="true" ;;
    search_logs)  [[ "${PROFILE_TOOL_SEARCH_LOGS,,}"  == "true" ]] && allowed="true" ;;
    hash_file)    [[ "${PROFILE_TOOL_HASH_FILE,,}"    == "true" ]] && allowed="true" ;;
  esac
  [[ "$allowed" == "true" ]] || die "Tool not permitted by current profile: $tool"
}

# -------------- Safe Utilities --------------

cmd_read_file() {
  enforce_tool_allowed "read_file"
  local path="$1"
  [[ -f "$path" ]] || die "File not found: $path"
  # Redact obvious secrets (simple heuristic)
  sed -E '
    s/(-----BEGIN [A-Z ]+PRIVATE KEY-----).*(-----END [A-Z ]+PRIVATE KEY-----)/\1[REDACTED]\2/g;
    s/([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})/[redacted-email]/g;
    s/([0-9]{1,3}\.){3}[0-9]{1,3}/[redacted-ip]/g;
  ' "$path"
}

cmd_list_dir() {
  local path="$1"
  [[ -d "$path" ]] || die "Directory not found: $path"
  ls -1A "$path"
}

cmd_hash_file() {
  enforce_tool_allowed "hash_file"
  local path="$1"
  [[ -f "$path" ]] || die "File not found: $path"
  if have_cmd sha256sum; then
    sha256sum "$path" | awk '{print $1}'
  elif have_cmd shasum; then
    shasum -a 256 "$path" | awk '{print $1}'
  else
    die "No sha256 tool found (sha256sum or shasum)."
  fi
}

cmd_search_logs() {
  enforce_tool_allowed "search_logs"
  local glob="$1"
  local regex="$2"
  shopt -s nullglob
  local files=( $glob )
  [[ ${#files[@]} -gt 0 ]] || die "No files match glob: $glob"
  for f in "${files[@]}"; do
    nl -ba "$f" | grep -E "$regex" || true
  done
}

cmd_run_command() {
  enforce_tool_allowed "run_command"
  local raw="$*"
  echo ">>> DRY‑RUN PREVIEW:"
  echo "$raw"
  if ! require_consent "Execute the above command?"; then
    echo "Denied by user."
    return 1
  fi
  eval "$raw"
}

# -------------- AI Inference Hook (stub) --------------

ai_infer() {
  # Stubbed local inference function.
  # When you have a local runtime, wire it here (llama.cpp, etc.)
  # Example (pseudo):
  #   "$GUARDOS_AI_RUNTIME" -m "$GUARDOS_MODEL_PATH" -p "$1" -n "$GUARDOS_MAX_TOKENS" ...
  #
  # For now, we return a deterministic placeholder to prove the pipeline.
  local prompt="$1"
  echo "[AI-STUB:$GUARDOS_MODEL_ID] $prompt"
}

cmd_summarize_file() {
  local path="$1"
  [[ -f "$path" ]] || die "File not found: $path"
  # Minimal safe pre‑processing
  local head_tail
  head_tail="$( (head -n 50 "$path"; echo; echo "[…snip…]"; echo; tail -n 50 "$path") 2>/dev/null )"
  # Call AI (stub)
  local sys_prompt user_prompt
  sys_prompt="$(cat "$GUARDOS_PROMPT_GUARDPANEL" 2>/dev/null || echo "You are GuardPanel running locally.")"
  user_prompt="Summarize the key points from the following file excerpt. Be concise.\n\n${head_tail}"
  ai_infer "$sys_prompt

$user_prompt"
}

# -------------- Usage --------------

usage() {
  cat <<EOF
GuardPanel CLI (pre‑alpha)

USAGE:
  $(basename "$0") <command> [args]

COMMANDS:
  # Safe utilities
  read-file <path>             Read a text file with basic redaction
  list-dir <path>              List directory entries
  hash-file <path>             Print SHA256 of a file
  search-logs <glob> <regex>   Search matching log files with regex

  # Controlled / consented
  run <shell command>          Dry‑run preview; ask consent before execute

  # AI‑assisted (stub)
  summarize-file <path>        Summarize a file (AI stub call)

  # Info
  show-config                  Print active config/profile summary
  help                         Show this help

NOTES:
  - Current mode: $GUARDOS_AI_MODE (Local‑Only blocks network).
  - Policies: $GUARDOS_POLICY_SAFETY, $GUARDOS_POLICY_TOOLS
  - Profile:  $GUARDOS_PROFILE
EOF
}

show_config() {
  cat <<EOF
GuardPanel — Active Configuration
---------------------------------
Mode:              $GUARDOS_AI_MODE
Model ID:          $GUARDOS_MODEL_ID
Model Path:        ${GUARDOS_MODEL_PATH:-<unset>}
Runtime:           $GUARDOS_AI_RUNTIME
Max Tokens:        $GUARDOS_MAX_TOKENS
Temperature:       $GUARDOS_TEMP
Top-p:             $GUARDOS_TOP_P
Consent Required:  $GUARDOS_REQUIRE_CONSENT

Policies:
  Safety:          $GUARDOS_POLICY_SAFETY
  Tools:           $GUARDOS_POLICY_TOOLS

Profile:
  File:            $GUARDOS_PROFILE
  Tools:
    run_command:   ${PROFILE_TOOL_RUN_COMMAND:-false}
    read_file:     ${PROFILE_TOOL_READ_FILE:-false}
    write_file:    ${PROFILE_TOOL_WRITE_FILE:-false}
    search_logs:   ${PROFILE_TOOL_SEARCH_LOGS:-false}
    hash_file:     ${PROFILE_TOOL_HASH_FILE:-false}

Prompts:
  GuardPanel:      $GUARDOS_PROMPT_GUARDPANEL

Logs:
  Dir:             $GUARDOS_LOG_DIR
  Rotate (days):   $GUARDOS_LOG_ROTATE_DAYS
  Level:           $LOG_LEVEL
EOF
}

# -------------- Main --------------

main() {
  local cmd="${1:-help}"; shift || true

  case "$cmd" in
    read-file)       [[ $# -ge 1 ]] || die "Usage: read-file <path>";       cmd_read_file "$@";;
    list-dir)        [[ $# -ge 1 ]] || die "Usage: list-dir <path>";        cmd_list_dir "$@";;
    hash-file)       [[ $# -ge 1 ]] || die "Usage: hash-file <path>";       cmd_hash_file "$@";;
    search-logs)     [[ $# -ge 2 ]] || die "Usage: search-logs <glob> <regex>"; cmd_search_logs "$@";;
    run)             [[ $# -ge 1 ]] || die "Usage: run <shell command>";    cmd_run_command "$@";;

    summarize-file)  [[ $# -ge 1 ]] || die "Usage: summarize-file <path>";  cmd_summarize_file "$@";;

    show-config)     show_config;;
    help|-h|--help)  usage;;
    *)               usage; exit 1;;
  esac
}

main "$@"
