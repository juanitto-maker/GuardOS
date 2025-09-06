# Roadmap (High-Level)

**MVP (0.1)**
- Immutable base (NixOS profile) + Secure Boot + TPM‑sealed disk
- App sandboxing (Flatpak + portals) + per‑app firewall
- Aegis AI (local anomaly + small local LLM for explainable prompts)
- Basic Incident Response: app isolation, snapshots, rollback
- Hardware Tier 1: Framework 13/16, ThinkPad T480/X270, MinisForum UM790

**0.2**
- Micro‑VMs for high‑risk apps (Firecracker/KVM)
- Anti‑Evil‑Maid, attestation baselines
- DNS anomaly + DGA detection, WireGuard profiles (Home/Travel/Untrusted)

**0.3**
- Hunter Mode (honeypots, canary tokens, trap FS)
- Client‑side encrypted backup + passkeys
- Expanded hardware matrix + ARM64 beta

**1.0**
- Reproducible release pipeline (SLSA), Sigstore signing
- Optional zero‑knowledge Guardian Cloud for threat intel sync
