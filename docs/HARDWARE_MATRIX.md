# GuardOS Hardware Compatibility Matrix

> GuardOS targets **PC-class, x86_64 machines** with unlocked firmware and support for local AI inference.  
> It is not a Linux distro — it is a full secure operating system with offline AI and policy-based tooling.

---

## ✅ Recommended Test Devices (2025)

| Device         | BIOS Status   | RAM   | Notes                                     |
|----------------|---------------|-------|-------------------------------------------|
| ThinkPad X230  | Libreboot     | 8–16GB| Ideal baseline device; full unlock possible |
| ThinkPad T430  | Libreboot     | 8–16GB| Works with similar setup as X230          |
| ThinkPad T480  | Coreboot-compatible | 16GB+ | More modern; MLC inference possible       |
| HP EliteBook 840 G2 | Coreboot  | 8–16GB| Known Coreboot support                    |
| Pine64 RockPro64 | U-Boot      | 4–8GB | ARM-compatible (future stretch goal)      |

---

## 🧱 Minimum Hardware Requirements

| Component     | Requirement                        |
|---------------|------------------------------------|
| CPU           | x86_64, AVX2 recommended           |
| RAM           | 4GB minimum (6–8GB recommended)     |
| Disk          | 16GB SSD or greater                |
| Bootloader    | Libreboot, Coreboot, or unlocked BIOS |
| GPU           | Not required; CLI-first environment |
| TPM           | Not required for v0.1              |

---

## ❌ Incompatible / Untested (for now)

- Android phones, tablets
- Locked Chromebooks
- MacBooks with T2 chips
- ARM-only devices (unless otherwise stated)
- Devices requiring secure boot or signed BIOS blobs

---

## 🔧 Testing Phases

| Phase | Hardware Focus                  | Goals                          |
|-------|---------------------------------|--------------------------------|
| Phase 1 | Libreboot ThinkPads (X230, T430) | Profile testing, safe shell tools |
| Phase 2 | Coreboot modern ThinkPads       | GPU test, power sandboxing     |
| Phase 3 | Pine64 or RISC-V dev boards     | Stretch: embedded GuardOS-lite |
| Phase 4 | Hardened multi-core systems     | Run full LLM (Phi-2) locally   |

---

## 🧩 How to Contribute Hardware Reports

If you test GuardOS tools on your device (even in shell-only mode):

1. Create a new issue using the `hardware.yaml` template.
2. Include:
   - CPU, RAM, GPU, firmware type (Libreboot/Coreboot/etc)
   - Whether `guardpanel/cli.sh` works
   - Whether `hunter/` detects your logs
   - Any failures or suggestions

Community-confirmed devices will be added to this list in future updates.
