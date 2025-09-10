# GuardOS — Security Model (Onion Architecture Deep‑Dive)

> This document supplements the primary security model in the repo root.
> It focuses specifically on GuardOS’s **layered (“onion”) defenses** and
> how profiles, policies, and local‑only AI enforce zero‑trust behavior.

---

## 🧅 Layer 1 — Physical & Firmware

| Focus | Details |
|------|---------|
| Firmware | Libreboot/Coreboot preferred; avoid opaque OEM blobs when possible |
| Install | Physical presence required for flashing; operator‑owned keys only |
| IDs | No binding to device serials/MACs by default; minimize unique identifiers |

**Mitigations:** bootkits, firmware backdoors, invisible pre‑OS persistence.

---

## 🧱 Layer 2 — Base System & Filesystem

| Focus | Details |
|------|---------|
| Minimalism | Small, auditable userspace; no GUI bloat in early milestones |
| Mount flags | `noexec`, `nodev`, `nosuid`, tmpfs on `/tmp` (per profile) |
| RO options | Read‑only root (planned) to reduce runtime tampering |
| Permissions | Profiles declare users, groups, allowed executable paths |

**Mitigations:** drive‑by persistence, privilege escalation, lateral movement.

---

## 🧠 Layer 3 — AI Tool Sandbox (Local‑Only by Default)

| Focus | Details |
|------|---------|
| Local models | No API keys; GGUF models run locally only |
| Policies | `ai/policies/safety.yaml`, `ai/policies/tool_rules.yaml` are mandatory gates |
| Consent | `run_command`, `write_file`, and network‑sensitive actions require explicit approval |
| Deny‑lists | Secrets/PII patterns blocked/redacted before display or logs |

**Mitigations:** prompt injection → covert exfiltration, over‑permissioned agents.

---

## 👁️ Layer 4 — GuardPanel Prompt & Tools

| Focus | Details |
|------|---------|
| System prompt | `ai/prompts/guardpanel/base.md` is open and auditable |
| Tool manifest | `ai/prompts/guardpanel/tools.json` strictly enumerates callable tools |
| Output hygiene | PII redaction in `read_file`, scrubbed transcripts, bounded tokens |
| Network stance | In `local` mode, all outbound network is denied by policy and code paths |

**Mitigations:** hallucinated “fetches,” unprompted side‑effects, data leakage.

---

## 🕵️ Layer 5 — Hunter (Threat Detection)

| Focus | Details |
|------|---------|
| Offline scans | `guardos/hunter/detect_threats.sh` parses logs locally |
| Patterns | SSH brute‑force, sudo misuse, kernel oops/segfault, suspicious cron |
| Redaction | Emails/IPs/secrets masked in findings and JSON output |
| Extensible | Rules are simple regex; easy to review and extend per profile |

**Mitigations:** stealthy compromises hiding in noisy logs.

---

## 🧬 Layer 6 — Profiles & Policy Governance

| Focus | Details |
|------|---------|
| YAML profiles | `profiles/*.yaml` define modes, tools, and consent requirements |
| Validation | `guardos/aegis/validate_config.sh` enforces structure and references |
| Mode matrix | `local` (no network), `hybrid`/`cloud` (future, via Guard‑Tunnel with consent) |
| Auditable | All decisions stem from text files + shell code; no hidden state |

**Mitigations:** misconfiguration drift, accidental privilege expansion.

---

## 🌐 Layer 7 — Guard‑Tunnel (Future, Opt‑In)

| Focus | Details |
|------|---------|
| Transport | Noise/WireGuard‑class tunnel; device‑bound keys; ephemeral sessions |
| Scope | Only for user‑approved tasks exceeding local capacity |
| Minimization | Redact/strip inputs locally before any tunneling |

**Mitigations:** metadata leaks, cloud lock‑in, overexposed surface area.

---

## ✅ Principles at a Glance

- **Local‑first**: fully functional offline; no API keys.  
- **Consent‑first**: risky actions previewed, never silent.  
- **Policy‑driven**: YAML + guards are the source of truth.  
- **Redaction‑by‑default**: outputs and logs are scrubbed.  
- **Auditable**: everything is text; nothing is hidden.

---

## 🔗 Cross‑References

- Root **Security Model** (canonical): `./SECURITY_MODEL.md`
- Policies: `ai/policies/safety.yaml`, `ai/policies/tool_rules.yaml`
- GuardPanel: `guardos/guardpanel/cli.sh`, `ai/prompts/guardpanel/*`
- Aegis validator: `guardos/aegis/validate_config.sh`
- Hunter: `guardos/hunter/detect_threats.sh`
