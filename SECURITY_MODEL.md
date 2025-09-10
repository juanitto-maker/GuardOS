# # 🛡️ GuardOS Security Model

> Last updated: 2025-09-10  
> Maintainer: GuardOS Core Team  
> License: GNU GPLv3

> 🧅 See also: [Onion Architecture Deep-Dive](docs/SECURITY_MODEL_ONION.md) for a layered breakdown of GuardOS security layers.

This document outlines the comprehensive security model of **GuardOS** — a secure-by-design operating system built for hardened, user-owned computing. It details:

- What attack vectors GuardOS protects against by default.
- What it mitigates partially or indirectly.
- What threats require hardware-level or user-side actions.
- Why GuardOS goes beyond traditional OS security.

---

## 🧅 1. Layered "Onion Security Model"

GuardOS is built using an **onion-layer model** of security:

```
🧠 User Behavior
  ⇧
🤖 AI (local-only, no surveillance)
  ⇧
🌐 Network (VPN, firewall, no cert injection)
  ⇧
🗂️ User Space (sandboxed apps, permissions)
  ⇧
🧱 System Services (signed daemons, no telemetry)
  ⇧
🧬 Kernel & Init (immutable, signed boot)
  ⇧
🔐 Core Boot (Libreboot/Coreboot, TPM, Heads)
```

Each layer assumes the lower layers could be compromised and defends against them.

---

## 🧷 2. Summary Table — Threat Categories vs GuardOS Coverage

| Category                           | GuardOS Protection | Supplementary Measures                      |
|------------------------------------|---------------------|----------------------------------------------|
| Physical extraction (GreyKey)      | ✅ Full disk encryption | Use strong passphrase, enable TPM           |
| Post-seizure malware (evil maid)   | ✅ Verified boot & alerts | Enable Heads with USB/GPG validation    |
| Remote exploits (0-click, Pegasus) | ✅ Minimal attack surface | Avoid risky apps, stay updated            |
| Modem/SS7 attacks                  | ✅ Not applicable (no baseband) | Use modemless hardware or disable radios |
| Certificate injection (MITM)       | ✅ CA pinning, no AV certs | Avoid installing untrusted apps           |
| Firmware/BIOS backdoors            | ⚠️ Partially mitigated | Flash Coreboot/Libreboot, disable ME       |
| Supply chain backdoors             | ⚠️ Limited          | Buy vetted hardware, hash verification     |
| Spyware / Stalkerware apps         | ✅ Sandboxed apps   | Limit permissions, audit apps regularly     |
| AI screen surveillance             | ✅ Disabled by design | No Copilot, no Recall                      |
| IMSI/Stingray radio spying         | ✅ No cellular radios | Remove WWAN cards, use MAC randomization    |
| USB malware / BadUSB               | ✅ No autorun, mount control | Avoid unknown USBs                    |
| User error / phishing              | ❌ Not OS-solvable | Train user, use password managers          |
---

## 🔓 3. Physical Access Attacks

### 🧪 Threat:
- Device seizure (airport, home raids)
- GreyKey, Celebrite data extraction
- Evil Maid attacks (implants during unattended access)

### 🛡️ GuardOS Defense:
- **Full-disk encryption (LUKS2)** with strong passphrase
- **TPM-integrated unlocking** (hardware-bound key sealing)
- **Verified Boot via Heads** (detects kernel tampering)
- **No biometric unlocks** (resists spoofing)
- **Read-only root partition** (immutable without rebuild)

### 🛠️ Recommended Extras:
- Flash **Coreboot or Libreboot** to remove Intel ME/UEFI
- Install **Heads** to detect tampering at boot
- Store signing keys on USB + Nitrokey/OnlyKey

---

## 📡 4. Remote Exploits (Zero-Click / Pegasus-style)

### 🧪 Threat:
- Remote RCE exploits via SMS, image, email
- NSO Group malware (Pegasus)
- Zero-day vulnerabilities in messaging/media apps

### 🛡️ GuardOS Defense:
- **No bundled messaging/media apps**
- Hardened **minimalist userland**
- **App sandboxing** and **system call filtering**
- **No Google Play, no Apple CoreServices**

### 🛠️ Recommended Extras:
- Apply updates regularly
- Use only open-source, reviewed apps (e.g. from F-Droid)

---

---

## 📶 5. Modem Exploits & SS7 Attacks

### 🧪 Threat:
- SimJacker (SIM-based execution via SS7)
- Silent SMS location triangulation
- Remote modem control (e.g. via Exynos baseband bugs)
- OTA baseband firmware injection

### 🛡️ GuardOS Defense:
- **GuardOS targets PCs/laptops by default**, which **do not include a modem or baseband radio stack**
- **No support for cellular/WWAN by design**
- All network interfaces are **user-visible and toggleable**

### 🛠️ Recommended Extras (for future mobile builds):
- Use hardware-separated modems (USB tethering only)
- Strict firewalling of modem access
- Isolate SIM and modem firmware OTA processes
- Disable cellular entirely for sensitive use

---

## 🔐 6. Supply Chain Attacks (Hardware & Software)

### 🧪 Threat:
- Malicious firmware inside cameras, keyboards, Wi-Fi chips
- Pre-installed rootkits or implants in BIOS/UEFI
- Backdoors in blobs (e.g. Broadcom Wi-Fi firmware)
- Infected open-source packages (e.g. NPM, PyPI)

### 🛡️ GuardOS Defense:
- Minimal driver set, **only signed & hashed kernel modules**
- **No automatic cloud updates** from OEMs
- Kernel + userland are **build-reproducible** (planned)

### 🛠️ Recommended Extras:
- Flash **Libreboot** or **Coreboot**
- Use **me_cleaner** to disable Intel ME
- Prefer vetted open hardware: Pine64, ThinkPad X230/T400, Novacustom
- Use USB devices instead of onboard blobs when possible
- Consider verifiable builds (e.g. NixOS/Fedora Silverblue model)

---

## 🌐 7. Network Attacks (Man-in-the-Middle, TLS Interception)

### 🧪 Threat:
- TLS certificate injection (via apps like Avast or gov software)
- Public Wi-Fi MITM attacks
- DNS hijacking, ARP spoofing, captive portal injections

### 🛡️ GuardOS Defense:
- Uses **strict TLS validation**, with optional **CA pinning**
- **No system-wide trust of new root certs** without full admin path
- Supports **encrypted DNS (DoH/DoT)** and custom resolvers
- Built-in **firewall tools** to detect ARP/DNS anomalies
- No auto-connect to untrusted Wi-Fi networks

### 🛠️ Recommended Extras:
- Always use **VPN-first** configurations (Mullvad, etc.)
- Disable unnecessary Wi-Fi radios
- Avoid installing apps that install certificates

---

## 👁️ 8. AI Copilot and Client-side Surveillance

### 🧪 Threat:
- OS-integrated AI systems (e.g. Microsoft Recall, Gemini, Copilot)
- Screen scraping and OCR of user activity
- Local "shadow index" of everything you do

### 🛡️ GuardOS Defense:
- **No built-in AI monitoring or Copilot systems**
- **All AI models are local-only and prompt-triggered**
- No app is allowed persistent screen/mic access by default
- Promotes **AI without surveillance**, with user-controlled permissions

### 🛠️ Recommended Extras:
- Use **air-gapped compute devices** for highly sensitive use
- Never install proprietary AI companions
- Enable GuardOS’s default AI sandbox limits

---

## 🤖 9. Spyware & Stalkerware Apps

### 🧪 Threat:
- Parental control apps repurposed for surveillance
- Keyloggers, location trackers, microphone recorders
- Hidden app overlays that mimic system UIs

### 🛡️ GuardOS Defense:
- **No app store** or side-loading by default
- **Explicit permissions required** for all sensors
- Apps are sandboxed with **AppArmor/SELinux policies**
- GUI overlay warnings built-in
- Users encouraged to audit installed apps via CLI/UI

### 🛠️ Recommended Extras:
- Never grant location/camera/mic to untrusted apps
- Use **system-level toggles** to disable sensors
- Periodically scan installed apps via audit tool

---

## 📲 10. Radio-based Tracking & IMSI Catchers

### 🧪 Threat:
- Fake cell towers (Stingrays, Dirtbox)
- IMSI tracking of device presence
- Geofencing via radio fingerprinting

### 🛡️ GuardOS Defense:
- **Laptops/PCs don’t include cellular radios**
- **MAC address randomization enabled**
- **No telemetry or beaconing** by background apps

### 🛠️ Recommended Extras:
- Physically remove WWAN modules from laptop if present
- Use **Ethernet when possible**
- When using Wi-Fi: rotate MAC + use VPN

---

---

## 🧬 11. Firmware / BIOS / UEFI Rootkits

### 🧪 Threat:
- Persistent implants in BIOS/UEFI firmware
- Exploits in Secure Boot implementations
- Malicious updates from OEM servers
- Hidden system management mode (SMM) code

### 🛡️ GuardOS Defense:
- **Support for Coreboot/Libreboot** firmware
- **No dependence on UEFI Secure Boot**
- **Heads-compatible boot verification** using TPM
- Verified kernel and initrd at boot

### 🛠️ Recommended Extras:
- Flash **Libreboot** or **Coreboot** with Heads on supported laptops
- Store boot key on external USB with GPG signing
- Never apply OEM BIOS updates unless source-verified

---

## 🧠 12. Human Error & Social Engineering

### 🧪 Threat:
- Phishing (email, SMS, fake login pages)
- Shoulder surfing, stolen credentials
- Trusted party betrayal
- USB baiting or device swaps

### 🛡️ GuardOS Defense:
- Educates users on **data minimalism and threat awareness**
- Enforces strong passwords + avoids biometric fallback
- Defaults to **no automatic USB mounting**, **no autorun**

### 🛠️ Recommended Extras:
- Use password managers (Bitwarden offline mode or KeePassXC)
- Never trust unsolicited links or "tech support" requests
- Lock screen manually when away
- Use 2FA with FIDO2 hardware keys

---

## 🪠 13. Memory, Swap, and Metadata Leakage

### 🧪 Threat:
- Residual data in swap, temp files, crash logs
- File metadata (EXIF, timestamps, etc.)
- Unencrypted hibernation files

### 🛡️ GuardOS Defense:
- **Encrypted swap** (if enabled)
- Cleans **`/tmp`, `/var/tmp`, and cache** at boot
- Optional **metadata-scrubbing scripts**
- No background crash reporting (manual logs only)

### 🛠️ Recommended Extras:
- Use `mat2` or `exiftool` before sharing files
- Disable hibernation if not needed
- Zero out free space periodically (`zerofree`, `fstrim`)

---

## ⚠️ 14. Known Limitations

GuardOS reduces a vast majority of known attack vectors, but **no OS can eliminate all risk**. The following remain challenges:

| Risk                                    | Reason                                           |
|-----------------------------------------|--------------------------------------------------|
| Hardware implants in SoCs or Wi-Fi      | Requires trusted fabrication & open hardware     |
| Spectre/Meltdown-like side-channels     | Partially mitigated by microcode & kernel flags |
| Baseband backdoors (on phones)          | Avoided by no baseband in PC builds              |
| Human phishing or coercion              | Not solvable by OS alone                         |
| Attacks via unvetted third-party parts  | User must select trusted vendors                 |

---

## 🚧 15. Future Work

GuardOS is a living security architecture. The following enhancements are under consideration:

- ✅ Coreboot + Heads support on all compatible laptops
- ✅ Fully reproducible ISO builds with hash transparency
- ✅ Optional **air-gap mode** with no network stack
- ✅ `guardian-cli` for audit/self-check of system security
- ✅ OnlyKey/YubiKey integration for unlocking & 2FA
- ✅ Mobile variant (GuardPhone) with hardened baseband

---

## 🧠 16. Security Philosophy

GuardOS is built around these principles:

- 🔐 **User-first, not vendor-first** — the system belongs to you, not to OEMs or cloud providers.
- 🪶 **Minimalism = Security** — fewer apps and services = fewer vulnerabilities.
- 🧱 **Immutable and auditable** — signed boot, reproducible builds, tamper detection.
- 🔎 **No surveillance AI** — no Copilot, no Recall, no background screen scanning.
- 🛑 **Zero trust by default** — even system daemons are sandboxed.

We believe true security requires visibility, control, and *intentional simplicity*.

---

## 📊 17. Comparison to Other Secure OSes

| Feature                             | GuardOS | QubesOS | GrapheneOS |
|-------------------------------------|---------|---------|------------|
| Hardware BIOS flashing supported    | ✅ Yes  | ✅ Yes  | ⚠️ Partial |
| Heads/TPM verified boot             | ✅ Yes  | ✅ Yes  | ❌ No      |
| Sandboxed apps                      | ✅ Yes  | ✅ Yes  | ✅ Yes     |
| App permissions & mic/cam toggles   | ✅ Yes  | ⚠️ Mixed | ✅ Yes     |
| Integrated AI surveillance          | ❌ None | ❌ None | ❌ None    |
| Local-only LLM tools (optional)     | ✅ Yes  | ❌ No   | ❌ No      |
| Target device                       | 🖥 PC   | 🖥 PC   | 📱 Mobile  |

---

## 📘 18. Further Reading

- [Libreboot project](https://libreboot.org/)
- [me_cleaner](https://github.com/corna/me_cleaner)
- [QubesOS Threat Model](https://www.qubes-os.org/security/)
- [Pegasus Forensic Report (Amnesty)](https://www.amnesty.org/en/latest/research/2021/07/forensic-methodology-report-how-to-catch-nso-group-pegasus/)

---

## ✅ 19. Conclusion

GuardOS is designed to be:

- 🔐 Secure by architecture  
- 🧠 Private by principle  
- 🧱 Modular by design  

By combining hardened open-source software with vetted hardware and zero surveillance tooling, GuardOS brings military-grade protection to everyday users — while respecting freedom and transparency.

We invite ethical hackers, security researchers, and concerned citizens to audit, contribute, and strengthen GuardOS.

> “Security is not a product — it’s a practice.”  
> — GuardOS Core Team

---
