# GuardOS Test Matrix

Status-driven tests that map directly to the roadmap. Keep this file small and living; details belong in existing docs:
- Roadmap: [`/ROADMAP.md`](../ROADMAP.md)
- Hardware notes: [`docs/HARDWARE_MATRIX.md`](./HARDWARE_MATRIX.md)
- Model overview: [`docs/SECURITY_MODEL_ONION.md`](./SECURITY_MODEL_ONION.md)

> Devices covered here: **QEMU (baseline), ThinkPad X230 (Tier‑1), T420 (Tier‑1 legacy), T480 (Tier‑1 modern)**

---

## Milestone Legend

- 🧪 v0.2 — Developer Kickstart (flake builds, QEMU boot smoke)
- 🚀 v0.3 — Pre‑Alpha Boot (QEMU guarded desktop, basic Aegis log)
- 🔐 v0.4 — Alpha on Reference Hardware (X230/T480/T420)
- 📦 v0.5 — Beta Installer & Updates (CLI install, declarative updates)
- 🎯 v1.0 — Bootable & Working (MVP)

---

## 1) QEMU (Baseline)

| Milestone | Tests | Pass Criteria |
|---|---|---|
| 🧪 v0.2 | `build.sh` produces ISO/IMG; boots to login (Wayland if available) | Image builds reproducibly (checksum); VM reaches greeter/shell |
| 🚀 v0.3 | Net presets load (egress-first); Flatpak runtime works; Aegis logs events | Browser Flatpak launches; Aegis shows 3 sample events; no network for non-whitelisted apps |
| 🔐 v0.4 | Snapshot/rollback (btrfs/ZFS pick); USB quarantine prompt (virtual USB) | Rollback returns to previous gen; virtual USB blocked until approved |
| 📦 v0.5 | CLI installer (disk layout, user, LUKS) | Fresh VM install completes; reboot unlocks disk; first-boot wizard runs |
| 🎯 v1.0 | Signed artifacts + SBOM attached; smoke tests green | Checksums/attestations verified; `run-tests.sh` all green |

---

## 2) ThinkPad X230 (Tier‑1)

**Pre‑flight** (once): BIOS accessible; TPM 1.2 present/enabled; SATA SSD; 8–16 GB RAM; Wi‑Fi card known-good (Atheros/Intel 6205).

| Milestone | Tests | Pass Criteria |
|---|---|---|
| 🧪 v0.2 | Boots dev image from USB; keyboard/trackpad/graphics OK | Reaches desktop; networking works; logs show no hard errors |
| 🚀 v0.3 | Flatpak baseline; Aegis logs (detect+log only) | Launch browser; Aegis shows process + net events; no unsolicited telemetry |
| 🔐 v0.4 | Secure boot path doc; TPM‑sealed LUKS; USB quarantine; per‑app net | Cold boot unlocks via TPM+passphrase; new USB blocked; non-browser apps blocked from network by default |
| 📦 v0.5 | CLI installer end‑to‑end + rollback test | Install → update → simulate broken update → rollback successful |
| 🎯 v1.0 | Daily driver sanity | Sleep/wake; Wi‑Fi toggle; external display; SafeView for web PDFs/images; Aegis explanations visible |

**Notes:** X230 also serves as the **Heads/Coreboot** reference later; for v1.0, stock firmware is acceptable with measured boot docs in progress.

---

## 3) ThinkPad T420 (Tier‑1 legacy)

**Pre‑flight:** Similar to X230; Coreboot/Libreboot optional; older Intel GPU path.

| Milestone | Tests | Pass Criteria |
|---|---|---|
| 🧪 v0.2 | Boots dev image; graphics stable (Wayland/Sway profile) | Sway session works; keyboard/trackpoint OK |
| 🚀 v0.3 | Flatpak + Aegis log | Same as X230 |
| 🔐 v0.4 | USB quarantine + per‑app net | Same as X230 |
| 📦 v0.5 | Installer + rollback | Same as X230 |
| 🎯 v1.0 | Legacy compatibility doc | Any deviations from X230 documented in `HARDWARE_MATRIX.md` |

---

## 4) ThinkPad T480 (Tier‑1 modern)

**Pre‑flight:** TPM 2.0, ME present (can’t be removed), NVMe/SATA, Intel graphics (Wayland GNOME).

| Milestone | Tests | Pass Criteria |
|---|---|---|
| 🧪 v0.2 | Boots dev image; Wayland GNOME profile OK | Greeter + session; touchpad gestures OK |
| 🚀 v0.3 | Flatpak + Aegis log | As per QEMU baseline |
| 🔐 v0.4 | TPM2‑sealed LUKS; USB quarantine; per‑app net | Disk unlock OK; USB prompt OK; non‑browser apps blocked from egress |
| 📦 v0.5 | Installer + declarative updates | `nixos-rebuild` path documented; rollback verified |
| 🎯 v1.0 | Battery/sleep, external display, camera/mic portals | All pass; privacy portals prompt as designed |

---

## 5) Cross‑Cutting Tests (All Devices)

- **SafeView v0:** Web‑downloaded PDF opens rasterized, **no network**, log recorded.
- **Aegis v0:** Explains **three** event types in plain language: new USB HID, first outbound DNS by a non‑whitelisted app, risky download.
- **Per‑App Network Policy:** Browser allowed; others block → allow once/forever via policy file (GUI coming).
- **Rollback:** Intentional broken update → boot previous generation.
- **Offline‑first pledge:** No outbound network from OS services/Aegis unless user explicitly enables cloud features.

---

## 6) Test Data & Scripts

- `tests/fixtures/`  
  - `pdf/malicious-like.pdf` (contains JS indicators; used only to validate SafeView rasterization)  
  - `files/untrusted.jpg` (simulates “downloaded-from-web” attribute)

- `tests/run-tests.sh` *(future)*  
  - QEMU boot smoke  
  - SafeView CLI check  
  - Policy file check (net block/allow)

---

## 7) Reporting

- File issues with device label: `device:x230`, `device:t420`, `device:t480`, or `env:qemu`.
- Include: ISO build hash, device, milestone, reproduction steps, and `journalctl -b` excerpt.
- For security-sensitive bugs, follow [`SECURITY.md`](../SECURITY.md).

---

## 8) What Success Looks Like per Milestone

- **v0.2:** Devs can build and boot in QEMU and on one real device (X230/T420/T480).  
- **v0.3:** Usable guarded desktop in QEMU; Aegis logs; Flatpak baseline.  
- **v0.4:** Same behaviors on **all three** laptops; USB guard + per‑app egress.  
- **v0.5:** Clean install path with rollback.  
- **v1.0:** Public image with signed artifacts, SBOM, and docs that match behavior.

---
