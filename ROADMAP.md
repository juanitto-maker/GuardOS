# GuardOS Roadmap

A phased plan with clear milestones up to **v1.0 bootable & working**. Items beyond v1 are future tracks.

---

## ✅ v0.1 – Conceptual Base (Done)
- [x] Modular OS architecture using NixOS
- [x] SECURITY_MODEL.md (onion model) published
- [x] Aegis watchdog concept (local, explainable)
- [x] Initial hardware shortlist (ThinkPad X230/T480, Framework 13/16, MinisForum)
- [x] Community outreach (GitHub, Reddit)

---

## 🚧 v0.2 – Developer Kickstart (WIP)
- [ ] Starter Nix flake + profiles (`profiles/dev-test.yaml`)
- [ ] `build.sh` helpers (ISO/image build, QEMU run)
- [ ] Flatpak sandboxing + portals baseline
- [ ] Contributor onboarding docs (`docs/CONTRIBUTING_GUIDE.md`)
- [ ] Minimal test matrix (QEMU + 1 ref device)

---

## 🔬 v0.3 – Pre‑Alpha Boot (QEMU)
- [ ] Boots ISO in QEMU to guarded desktop
- [ ] Base networking + firewall presets (egress‑first)
- [ ] Snapshot/rollback (Btrfs/ZFS; pick one)
- [ ] Early Aegis watchdog shell (detect + log only)
- [ ] Smoke tests (`run-tests.sh`) green in CI

---

## 🧪 v0.4 – Alpha on Reference Hardware
- [ ] Boots on **X230** and **T480** (or Framework 13) from ISO/USB
- [ ] Secure Boot path + TPM‑sealed LUKS (where applicable)
- [ ] User‑friendly first‑boot hardening prompts
- [ ] Flatpak + per‑app firewall working
- [ ] Incident Response basics: app isolation, snapshot, rollback

---

## 🧰 v0.5 – Beta Installer & Updates
- [ ] CLI installer (disk layout, user, SB keys enroll, LUKS)
- [ ] Declarative updates via `nixos-rebuild` with atomic rollback
- [ ] Telemetry: **off by default**, device‑ID optional, docs
- [ ] Aegis watchdog: explainable prompts, local‑only models optional
- [ ] Docs: INSTALL.md fleshed out with screenshots

---

## 🎯 v1.0 – Bootable & Working (MVP)
- [ ] Public bootable ISO image released
- [ ] Runs on **two reference laptops** end‑to‑end
- [ ] Hardened baseline: Secure Boot, TPM‑sealed disk, firewall, sandboxed apps
- [ ] Aegis watchdog: basic policy + human‑readable guidance
- [ ] Clear user docs (install, recover, update, incident response)
- [ ] Tagged release + signed checksums

---

## 🛡️ v2.0 – Hardening & Reproducibility (Post‑v1)
- [ ] Micro‑VM isolation for high‑risk apps (Firecracker/KVM)
- [ ] Anti‑Evil‑Maid + attestation baselines
- [ ] Reproducible builds pipeline (SLSA) + Sigstore signing
- [ ] Expanded test matrix (more ThinkPads, Minis, Framework)

---

## 🌐 v3.0 – Ecosystem Expansion (Post‑v2)
- [ ] ARM64 beta images (mini‑PCs/SBCs)
- [ ] Optional zero‑knowledge **Guardian Cloud** for threat intel sync
- [ ] Signed updates server + secure rollback strategy
- [ ] Extended hardware matrix + contributors’ guide for ports

---

### Reference Hardware (living list)
- Tier 1 (v1 target): Lenovo **X230**, **T480**, Framework 13
- Tier 2 (post‑v1): Framework 16, MinisForum UM series, ThinkPad X270/T14

> Issues labeled `good first issue` and `help wanted` map to the active milestone.
