# GuardOS v0.1 — Acceptance Criteria

> Version 0.1 is the first **working skeleton** of GuardOS.  
> It is **not a bootable OS** yet, but demonstrates:
> - the secure-by-design structure
> - working AI integrations (local-only)
> - validated profiles and policy enforcement
> - reproducible logic, with no API dependencies

---

## ✅ Must-Have Features for v0.1

### 1. 🔐 Profiles and Policy Validation

- [x] Profile structure defined in YAML (`profiles/minimal.yaml`, etc)
- [x] Profile validation tool (`aegis/validate_config.sh`)
- [x] Consent enforcement toggled by profile
- [x] Local-only AI mode with policy checks
- [x] Profile switchable at runtime

---

### 2. 🧠 Local AI Agent Framework

- [x] Shell-based GuardPanel CLI stub (`guardpanel/cli.sh`)
- [x] Can parse prompts, detect policies, enforce safety
- [x] Supports local stubbed LLM (e.g., Gemma, TinyLlama)
- [x] Redacts PII before showing logs or files
- [x] Modular tool registry (`ai/prompts/guardpanel/tools.json`)

---

### 3. 🧪 Tools: Secure by Default

- [x] Tools blocked by default unless profile allows
- [x] Commands like `read_file`, `hash_file`, `search_logs`, `run_command` all functional
- [x] `run_command` works with dry-run preview and requires user confirmation

---

### 4. 🔍 Threat Detection & Linting

- [x] `hunter/detect_threats.sh` scans logs with regex-based rules
- [x] Redacts email/IP/secrets before showing output
- [x] JSON and CLI output supported

---

### 5. 🛠️ Boot Logic Simulation

- [x] Simulated boot init (`system/boot_init.sh`) loads profile and launches GuardPanel
- [x] Default services (firewall, audit, panel) simulated
- [x] No real OS boot required

---

## ⏳ Optional (Stretch Goals for v0.1.x)

| Goal | Status |
|------|--------|
| Llama.cpp or MLC integration for real local model inference | ⏳ planned |
| Adapter runner for `ai_infer()` | ✅ stub exists |
| Text UI (gum, whiptail, etc.) | ⏳ design phase |
| `flake.nix` or `build.sh` | ⏳ post-v0.1.0 |
| Log rotation + transcript scrubber | ⏳ partial |
| Guard-Tunnel placeholder shell (no backend) | ⏳ designed only |

---

## 🚫 Explicitly Not In Scope (v0.1)

- ISO image or real bootloader
- Kernel/firmware hardening
- Persistent storage
- Remote updates or AI API keys
- Mobile or Android support

---

## ✅ Completion Check

Once this list is complete:
- Mark v0.1 tag
- Announce on GitHub with Discussions + logo
- Invite contributors to extend `aegis`, `hunter`, `guardpanel`, or test on real hardware
