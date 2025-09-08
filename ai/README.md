# GuardOS AI

GuardOS ships with **local‑first AI**. No model weights are committed to this repo.  
Instead, you get a **model registry**, **policy controls**, and **prompts/adapters** so users can choose what to run on‑device (or later, via Guard‑Tunnel).

---

## Modes

- **Local‑Only (default):** All inference runs on the machine. No network calls.  
- **Hybrid (future):** Routine tasks local; heavy tasks optionally use Guard‑Tunnel with explicit user consent.  
- **Cloud‑Locked (future):** Managed accuracy via remote providers over Guard‑Tunnel.

Mode is selected by configuration (see below). Local‑Only **disables all network I/O** for AI runners.

---

## Structure

```text
ai/
├─ README.md
├─ models/
│  ├─ registry.yaml          # Canonical list of supported models
│  └─ cards/                 # One‑pagers per model (capabilities, limits, licenses)
├─ policies/
│  ├─ safety.yaml            # Guardrails & data‑handling rules
│  └─ tool_rules.yaml        # Tool‑use contracts (consent, allowlists)
├─ prompts/                  # Role/system prompts & tool manifests
├─ adapters/                 # Thin glue between GuardOS services and AI calls
├─ runners/                  # CLI/daemon shims that respect policy and mode
├─ evals/                    # Eval datasets & scoring (optional)
└─ logs/                     # (sanitized) transcripts & metrics for regression
