[![Donate](https://img.shields.io/badge/Donate-Ko--fi-blueviolet?logo=ko-fi)](https://ko-fi.com/guardos)

# GuardOS — AI‑Armored Personal Operating System (Open Source)

**GuardOS** hardens an individual computer (“cell”) using a layered (Onion) model:
- Immutable base OS + verified boot
- Strict app sandboxing & per‑app firewall
- Local AI for anomaly detection + explainable prompts
- Zero‑trust defaults, zero‑knowledge (opt‑in cloud)

> Goal: “Military‑grade” resilience for everyday users, without breaking normal computing.

## Why GuardOS?
Traditional security focuses on the perimeter. Modern attacks move across layers: firmware, boot, OS, apps, network, cloud, and user. GuardOS defends **each layer** and binds them with a **local AI** (“Aegis”) that explains risk and suggests safe actions.

## Core Principles
- **Local‑first AI** (offline by default)
- **Zero trust on a single machine**
- **Immutable base, atomic rollback**
- **Explainable security prompts**
- **Open, auditable, reproducible builds**

## Quick Links
- 📐 [Architecture](docs/ARCHITECTURE.md)
- 🛡️ [Threat Model](docs/THREAT_MODEL.md)
- 🧠 [AI Stack](docs/AI_STACK.md)
- 🧩 [Policy Engine](docs/POLICY_ENGINE.md)
- 🧯 [Incident Response](docs/INCIDENT_RESPONSE.md)
- 🧭 [Roadmap](ROADMAP.md)
- 🧱 [Build](BUILD.md) · 🚀 [Install](INSTALL.md)
- 💻 [Hardware & Support Matrix](docs/HARDWARE.md) / (docs/DEVICE_SUPPORT_MATRIX.md)
- 🔒 [Security Policy](SECURITY.md)
- 🤝 [Contributing](CONTRIBUTING.md) · 🧭 [Governance](GOVERNANCE.md)
- 📣 [Code of Conduct](CODE_OF_CONDUCT.md)

## 📖 GuardOS Genesis

Want to understand how GuardOS was born, the philosophy behind it, and how the onion‑layer model evolved?

Read the full literal transcript here:  
👉 [**GENESYS.md**](./GENESYS.md) — *GuardOS Genesis Log: Literal Transcript*

## Status
This is an early, community‑led project. Expect rapid iteration. Join us in discussions and issues.

## 🔐 Security Model

GuardOS is built with a comprehensive, layered defense architecture known as the **Onion Security Model**, tackling modern threats such as:

- Physical device seizure & forensic extraction (e.g., GreyKey)
- Remote 0-click malware (e.g., Pegasus)
- Firmware/BIOS-level implants
- TLS interception and certificate injection
- AI-based surveillance (e.g., Recall, Copilot, Gemini)
- Stalkerware, USB malware, SS7 modem exploits

👉 **[Read the full GuardOS Security Model →](./SECURITY_MODEL.md)**

## 💬 Community & Support

Want to ask questions, share ideas, or get help with GuardOS?

Join the official GitHub Discussions:  
👉 **[GuardOS Discussions](https://github.com/juanitto-maker/GuardOS/discussions)**

This is the place to:
- Ask for help or clarification
- Share feature requests and ideas
- Follow project updates
- Connect with other contributors

We're building GuardOS together — your input is welcome!

> 💡 For bug reports or technical issues, please use [Issues](https://github.com/juanitto-maker/GuardOS/issues).

[![Security](https://img.shields.io/badge/security-GitHub%20Advanced-blue?logo=github)](../../security/policy)

---

## 🚧 Project Progress [Updated: Sept 12, 2025]

📍 See full [ROADMAP.md →](https://github.com/juanitto-maker/GuardOS/blob/main/ROADMAP.md)

- ✅ v0.1: Core architecture, SECURITY_MODEL.md, and Aegis AI concept drafted
- ✅ Reference hardware selected: ThinkPad X230, T480, Framework 13
- ✅ Community feedback loop started (Reddit + GitHub)
- 🔄 v0.2: Nix flake + profiles under development (`profiles/dev-test.yaml`)
- 🔄 v0.2: Flatpak sandboxing + per-app firewall config ongoing
- 🔄 v0.2: Contributor onboarding docs being drafted
- 🧪 v0.3: QEMU bootable ISO in planning stage
- 🧠 Looking for contributors on:
  - Aegis watchdog shell scripting (detection + logging)
  - Flatpak sandbox and firewall testing
  - Installer polish (`build.sh`)
  - Real-device reproducibility feedback

---

---

## 🤝 How to Contribute

You **don’t need to be a Nix guru** — GuardOS welcomes help from all security-minded devs.

### Good first tasks:
- Improve the installer (`build.sh`)
- Write or test watchdog scripts (Bash/Python)
- Suggest new security hardening techniques
- Test reproducibility on real hardware
- Translate documentation

Check [issues](https://github.com/juanitto-maker/GuardOS/issues) labeled `good first issue` or [open a discussion](https://github.com/juanitto-maker/GuardOS/discussions).

---

☕ Like it? Support the project at [ko-fi.com/guardos](https://ko-fi.com/guardos)

## License
See [LICENSE](LICENSE). SPDX: GPL-3.0-or-later


🙏 If you believe in privacy-first computing, [support GuardOS on Ko‑fi](https://ko-fi.com/guardos).
