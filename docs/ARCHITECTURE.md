# Architecture

## Layers (Onion Model)
0. Firmware/Hardware → measured boot, TPM anchors, anti‑evil‑maid
1. Bootloader/Kernel → signed kernel, IMA/EVM, lockdown
2. OS/Privilege → immutable base (Nix), A/B atomic updates, ephemeral admin
3. Apps → Flatpak/containers, portals, micro‑VMs for high‑risk
4. Network → eBPF/XDP firewall, per‑app egress allowlists, DoH + DGA detection, WireGuard
5. Identity/Cloud → passkeys/FIDO2, TPM‑sealed token vault, client‑side encrypted backups
6. Human → Secure Action Advisor, phishing classifier, USB quarantine, SafeView

## Aegis AI Stack
- **Watchtower**: anomaly detection (syscalls, FIM, DNS, flows)
- **Sage**: local LLM for explanations + policy recommendations
- **PolicyBrain**: learns habits, suggests tighter policies

## Data Flows
- Event bus (auditd/eBPF) → Watchtower → Sage (explain) → Policy action (allow/deny/isolate) → User prompt

## Update/Recovery
- A/B updates, reproducible builds, cosign signatures
- Read‑only recovery environment with firmware tools
