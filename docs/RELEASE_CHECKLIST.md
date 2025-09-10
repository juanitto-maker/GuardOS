# GuardOS — Release Checklist

> This checklist defines the required steps for every **versioned public release** of GuardOS — including pre-ISO versions (e.g., v0.1 shell prototype).  
> It ensures each release is consistent, verifiable, secure, and community-ready.

---

## ✅ 1. Tag Freeze

- [ ] Update `README.md` with new version and date
- [ ] Update `docs/ROADMAP.md` to mark milestone reached
- [ ] Update all `version:` fields in YAML/JSON files (e.g., `tools.json`, `registry.yaml`)
- [ ] Confirm that `GUARDOS_MODEL_ID` and `GUARDOS_AI_MODE` are sane in `.env.example`

---

## ✅ 2. Policy & Profile Lock

- [ ] Run `aegis/validate_config.sh` on all profiles:
  - [ ] `profiles/minimal.yaml`
  - [ ] `profiles/dev-test.yaml`
  - [ ] Any new hardware-specific ones
- [ ] Re-audit `ai/policies/safety.yaml` and `tool_rules.yaml`
- [ ] Confirm tool names match in `ai/prompts/guardpanel/tools.json`
- [ ] Confirm `guardpanel/cli.sh` works with each profile

---

## ✅ 3. Sanity & Reproducibility

- [ ] Run `system/boot_init.sh` with each profile
- [ ] Confirm `guardpanel/cli.sh` can:
  - [ ] show-config
  - [ ] read-file on known file
  - [ ] hash-file on test
  - [ ] summarize-file (returns stub, unless local LLM is wired)
- [ ] Run `hunter/detect_threats.sh` on sample log folder
- [ ] Confirm all outputs redact PII and secrets

---

## ✅ 4. File Hygiene

- [ ] `.env.example` is updated and safe (no real paths)
- [ ] All `*.md` have correct headings and version numbers
- [ ] All `*.sh` are:
  - [ ] LF line endings (`\n`, not `\r\n`)
  - [ ] `#!/usr/bin/env bash` shebang
  - [ ] `chmod +x` and clean syntax
- [ ] No `.DS_Store`, `.idea/`, or temp files in repo

---

## ✅ 5. GitHub Metadata

- [ ] Git tag created: `vX.Y.Z` with signed commit
- [ ] Tag message includes:
  - ✅ Summary of features
  - ✅ Link to `ACCEPTANCE_CRITERIA_v0.1.md`
  - ✅ Reminder that ISO boot is not included yet (if pre-boot)
- [ ] README includes updated project status:
  > _Status: Pre‑alpha. Shell‑only. Not bootable yet._

- [ ] Discussions pinned:
  - `📌 Vision & Roadmap`
  - `📌 GENESYS (Origin Transcript)`
  - `📌 How to Contribute Without Hardware`

---

## ✅ 6. Optional Release Assets

> *(Only for post-v0.1 builds with binaries or disk images)*

- [ ] `.tar.gz` or `.zip` archive of `/guardos`, `profiles/`, and `ai/` folders
- [ ] Build log (`releases/build-log-vX.Y.Z.txt`)
- [ ] Checksums:
  - [ ] `SHA256SUMS`
  - [ ] `SHA256SUMS.sig` (signed)
- [ ] ISO image (future milestone)
  - [ ] GPG-signed
  - [ ] `.sig` included
  - [ ] Public key hosted in GitHub profile and in README

---

## ✅ 7. Post-Release Actions

- [ ] Update `docs/ROADMAP.md` with next goals
- [ ] Post summary in GitHub Discussions
- [ ] Post to social (if public): Twitter, Mastodon, Ko-fi, etc.
- [ ] Ping early supporters or testers

---

✅ All done? Push the tag, open the repo, and let the mission begin.
