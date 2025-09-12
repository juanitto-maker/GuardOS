# GuardOS — Install & Test Guide

This guide walks you through installing and testing GuardOS on a real device or in a QEMU virtual machine.  
It assumes you're starting from a generated ISO/IMG using `build.sh` and `profiles/dev-test.yaml`.

---

## 🔧 Supported Devices (as of v0.2–v0.4)

| Device      | Tier | Boot | Install | Notes |
|-------------|------|------|---------|-------|
| ThinkPad X230 | 🥇 Tier‑1 | ✅ | ✅ | Best Coreboot support; 16 GB max RAM |
| ThinkPad T420 | 🥇 Tier‑1 Legacy | ✅ | ✅ | Libreboot-ready; lower performance |
| ThinkPad T480 | 🥇 Tier‑1 Modern | ✅ | ✅ | TPM2; ME not removable; full features |
| QEMU (x86_64) | ✅ Baseline | ✅ | ❌ | Used for smoke testing only |

---

## 🖥️ USB Boot (All Devices)

### Create the bootable USB:
```bash
sudo dd if=guardos-dev.img of=/dev/sdX bs=4M status=progress && sync
```
- Replace `/dev/sdX` with your USB device (be careful!)
- Use `bs=1M` or `4M` depending on distro

### BIOS settings:
- Disable Secure Boot (if present)
- Enable Legacy Boot / CSM if needed
- TPM must be enabled (recommended)
- Boot from USB — choose your stick

---

## 🧪 Quick Test Flow (Without Install)

| Step | Action | What to expect |
|------|--------|----------------|
| 1 | Boot from USB | Wayland session launches (GNOME/Sway) |
| 2 | Open `terminal`, run `flatpak list` | Basic apps pre-installed |
| 3 | Insert USB stick | Quarantine prompt should appear |
| 4 | Run `safeview untrusted.pdf` | Opens in sandboxed viewer |
| 5 | Launch browser | Ungoogled Chromium or Librewolf |
| 6 | Run `journalctl -b` | Check system messages, Aegis logs |

---

## 🧱 Full Install Path (CLI)

> ⚠️ Not stable until `v0.5` — only use for testing!

1. Reboot from USB, choose `Install to Disk` (manual)
2. Launch terminal:  
```bash
sudo guardos-install /dev/sdX
```
3. This:
   - Creates partitions
   - Encrypts disk via LUKS
   - Seeds TPM sealing
   - Copies root
   - Generates default config
4. Reboot and remove USB
5. Login → run `sudo nixos-rebuild switch` to test updates

---

## 🧪 Smoke Tests

| What to test | How to do it | Pass criteria |
|--------------|--------------|----------------|
| Wayland session | Boot live image | Greeter and session launch |
| Network block | Open terminal, run `ping` | Disabled unless Flatpak app |
| USB guard | Insert mouse or storage | Blocked with prompt |
| SafeView | `safeview untrusted.pdf` | Opens with no network access |
| Rollback | Rebuild with bad change → reboot | Select previous gen, it works |
| Logs | `journalctl`, `/var/log/aegis.log` | Events recorded, readable |

---

## 📥 Download Notes

All ISO/IMG releases will be published at:  
**[github.com/juanitto-maker/GuardOS/releases](https://github.com/juanitto-maker/GuardOS/releases)**  
Once stable, checksums and SBOMs will be included.

---

## 🧯 Troubleshooting

| Problem | Solution |
|---------|----------|
| "No bootable media" | Check dd command, use Etcher or `bs=1M` |
| X230 freezes at boot | Disable VT-d in BIOS |
| T480 mousepad glitch | Try alternate session (Sway) |
| Can’t run `safeview` | Flatpak may not be initialized yet |
| Install stuck at LUKS | Check TPM support or reflash BIOS |

---

## 🧩 Related Docs

- [`docs/TEST_MATRIX.md`](./TEST_MATRIX.md)
- [`docs/HARDWARE_MATRIX.md`](./HARDWARE_MATRIX.md)
- [`docs/SAFEVIEW.md`](./SAFEVIEW.md)
- [`README.md`](../README.md)
