# GuardOS — FAQ (Frequently Asked Questions)

---

## 🤖 Is GuardOS just a Linux distribution?

**No.** GuardOS is a full operating system architecture focused on:

- Local AI assistance (no cloud dependency)
- Offline-first design
- Strong security defaults (zero trust)
- AI-sandboxed tooling
- Reproducible builds and open supply chain

While it may use Linux kernel or common GNU userspace tools underneath, it is **not "just another distro"**.

---

## 🧠 Why does GuardOS use AI locally?

- To **eliminate API key risks**
- To **keep prompts, logs, and completions offline**
- To allow **consent-bound actions**, like summarizing logs or validating configs
- To build a future-proof platform that can use **offline LLMs**

All AI runs within strict profiles and policies (see `ai/policies/`).

---

## 🌐 Can I use GuardOS online?

Yes — **but not the AI** unless explicitly configured.  
Your apps and browsers can access the internet, but:

- AI agents operate in **Local Mode** by default
- All outbound AI calls are **disabled unless the user opts into `hybrid` or `cloud` mode**
- A future Guard‑Tunnel will allow encrypted p2p or endpoint access with full user control

---

## 🔐 Why not just use Qubes OS or Tails?

Qubes and Tails are excellent — GuardOS shares their spirit but differs:

| Feature                | Qubes/Tails         | GuardOS                         |
|------------------------|---------------------|----------------------------------|
| Threat model           | Whistleblower, Malware | Same, but adds AI enforcement |
| Local AI               | ❌ (none)            | ✅ (baked-in, sandboxed)         |
| Profiles               | Manual/complex       | YAML-defined, strict-by-default |
| Consent-based tools    | ❌                   | ✅ Always ask before action      |
| Airgap / offline       | ✅                   | ✅ + LLM support                 |

---

## 📦 Does GuardOS include LLM models?

**No.**  
We include:

- A model registry (`ai/models/registry.yaml`)
- SHA256 hashes
- Prompts and policy scaffolding
- Tool wrappers

You (the user) download the actual `.gguf` models and place them under `~/.guardos/models/…`.

---

## 📱 Does it work on Android or phones?

**No.** GuardOS is for **PC-class unlocked devices**, such as:

- ThinkPad X230 (Libreboot)
- T480 (Coreboot)
- Intel/AMD desktops or NUCs

Support for secure phones or RISC-V SBCs may be added in the future — but not now.

---

## 🔎 Can I inspect what the AI does?

Yes — fully.

- All prompts, logs, and responses are saved to `.guardos/logs/` (local-only)
- Redaction policies are open and auditable
- Profiles dictate what tools are allowed — nothing happens silently

---

## 🛠️ How do I contribute?

You don’t need hardware or code to help.

See:
- [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- [`docs/HARDWARE_MATRIX.md`](./HARDWARE_MATRIX.md)
- [`docs/ROADMAP.md`](./ROADMAP.md)

There are issues tagged `good first issue` — including docs, evals, model testing, red-team prompts, and more.

---

## 💬 Where can I ask questions?

Right here in GitHub Discussions — no Discord, no Telegram.  
You can also open issues using the `question` label.

---

Still confused?  
Run:

```bash
bash guardos/system/boot_init.sh
