#!/usr/bin/env bash
# GuardOS — Build / Validate / Package (pre‑alpha)
# Portable script (no sudo, no nix) to:
#  1) sanity-check repo layout
#  2) lint bash scripts
#  3) validate profiles & policies
#  4) optionally run simulated boot
#  5) package a clean tarball under ./dist/
#
# USAGE:
#   bash build.sh [check|package|all] [--boot] [--profile profiles/dev-test.yaml]
#
# EXAMPLES:
#   bash build.sh check
#   bash build.sh package --boot --profile profiles/minimal.yaml
#   bash build.sh all

set -euo pipefail

# ---------------- Config ----------------
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$REPO_ROOT/dist"
PROFILE="$REPO_ROOT/profiles/minimal.yaml"
DO_BOOT=false

# ---------------- Args ------------------
ACTION="${1:-check}"
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2;;
    --boot)    DO_BOOT=true; shift;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

# ---------------- Helpers ----------------
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required command: $1" >&2; exit 1; }; }
step() { echo; echo "==> $*"; }

list_bash_files() {
  # All tracked shell scripts we want to lint
  find "$REPO_ROOT" -type f -name "*.sh" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -print
}

# ---------------- Tasks ----------------
task_layout_check() {
  step "Checking repo layout"
  for path in \
    "$REPO_ROOT/guardos/guardpanel/cli.sh" \
    "$REPO_ROOT/guardos/aegis/validate_config.sh" \
    "$REPO_ROOT/guardos/hunter/detect_threats.sh" \
    "$REPO_ROOT/ai/policies/safety.yaml" \
    "$REPO_ROOT/ai/policies/tool_rules.yaml" \
    "$REPO_ROOT/ai/models/registry.yaml" \
    "$REPO_ROOT/ai/prompts/guardpanel/base.md" \
    "$PROFILE"
  do
    [[ -e "$path" ]] || { echo "Missing expected path: $path" >&2; exit 1; }
  done
  echo "OK: structure looks good."
}

task_shell_lint() {
  step "Linting shell scripts with bash -n"
  local ok=1
  while IFS= read -r f; do
    bash -n "$f" || ok=0
  done < <(list_bash_files)
  [[ $ok -eq 1 ]] || { echo "Shell syntax errors found." >&2; exit 1; }
  echo "OK: shell syntax clean."
}

task_profile_validate() {
  step "Validating profile: $PROFILE"
  bash "$REPO_ROOT/guardos/aegis/validate_config.sh" "$PROFILE" || {
    code=$?
    echo "Validator exit code: $code"
    exit "$code"
  }
  echo "OK: profile validated."
}

task_boot_sim() {
  if $DO_BOOT; then
    step "Simulated boot with $PROFILE"
    bash "$REPO_ROOT/guardos/system/boot_init.sh" "$PROFILE" || {
      echo "Boot simulation failed." >&2; exit 1;
    }
  else
    echo "(skip) use --boot to run simulated boot"
  fi
}

task_package() {
  step "Packaging pre‑alpha tarball"
  mkdir -p "$DIST_DIR"
  TS="$(date -u +%Y%m%d-%H%M%S)"
  NAME="GuardOS-prealpha-${TS}.tar.gz"

  # Exclude dev and transient files
  tar -czf "$DIST_DIR/$NAME" \
    --exclude-vcs \
    --exclude="./dist" \
    --exclude="*.tmp" \
    --exclude="*.log" \
    --exclude="*.swp" \
    --exclude="*~" \
    -C "$REPO_ROOT" \
    ai guardos profiles docs README.md LICENSE .env.example

  echo "OK: created $DIST_DIR/$NAME"
}

task_all() {
  task_layout_check
  task_shell_lint
  task_profile_validate
  task_boot_sim
  task_package
}

# ---------------- Main ----------------
case "$ACTION" in
  check)   task_layout_check; task_shell_lint; task_profile_validate; task_boot_sim ;;
  package) task_package ;;
  all)     task_all ;;
  *) echo "Usage: bash build.sh [check|package|all] [--boot] [--profile <file>]" >&2; exit 1;;
esac

echo
echo "Done."
