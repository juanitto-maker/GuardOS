# GuardOS AI

GuardOS ships with **local-first AI**. No model weights are committed to this repo.  
Instead, you get a **model registry**, **policy controls**, and **prompts/adapters** so users can choose what to run on‑device (or later, via Guard‑Tunnel).

---

## Modes

- **Local‑Only (default):** All inference runs on the device. No network calls.  
- **Hybrid (future):** Routine tasks local; heavy tasks optionally use Guard‑Tunnel with user consent.  
- **Cloud‑Locked (future):** Managed accuracy via cloud providers over Guard‑Tunnel.

Mode is selected by configuration (see below). Local‑Only **disables all network I/O** for AI runners.

---

## Structure

```text
ai/
├─ README.md
├─ models/
│  ├─ registry.yaml          # Canonical list of supported models
│  └─ cards/                 # One-pagers per model (capabilities, limits, licenses)
├─ policies/
│  └─ safety.yaml            # Guardrails & data-handling rules
├─ prompts/                  # (coming later) role prompts & tool manifests
├─ adapters/                 # (coming later) thin glue to GuardOS services
├─ runners/                  # (coming later) Termux-friendly CLIs/daemons
├─ evals/                    # (coming later) eval datasets & scoring
└─ logs/                     # (sanitized) transcripts & metrics for regression
```

---

## Local runtimes (Android‑friendly)

GuardOS targets **GGUF** models first because they run well on CPU:

- `llama.cpp` (GGUF): simple, reliable, broad quantization support.
- `MLC LLM` (optional): Android‑optimized builds, Vulkan acceleration.

> We do **not** vendor these tools here. Users install them locally, and GuardOS points to the user’s model cache (e.g., `~/.guardos/models/`).

---

## Model installation (concept)

1. Choose a model from [`ai/models/registry.yaml`](./models/registry.yaml)  
2. Download a recommended quantization from the **official source** or a known mirror  
3. Verify the **SHA256** hash from the registry  
4. Place the file under: `~/.guardos/models/<family>/<file>.gguf`

> Do not commit model weights to Git.

---

## Configuration

Set these environment variables (or a small `~/.guardos/ai.env`):

- `GUARDOS_AI_MODE` = `local` | `hybrid` | `cloud` (default: `local`)
- `GUARDOS_MODEL_ID` = e.g. `gemma-0.27b-q4km`
- `GUARDOS_MODEL_PATH` = full path to `.gguf` file when in Local‑Only
- `GUARDOS_MAX_TOKENS`, `GUARDOS_TEMP`, `GUARDOS_TOP_P` (optional)

> In **Local‑Only**, all network calls are hard‑disabled by policy.

---

## Security & Privacy

- **No weights in repo**; we publish hashes and licenses only  
- **Content minimization:** Local‑Only keeps prompts & outputs on device  
- **Guard‑Tunnel (future):** Noise/WireGuard‑class encryption, device‑bound keys, ephemeral sessions

See also:
- [`ai/policies/safety.yaml`](./policies/safety.yaml)
- [`docs/THREAT_MODEL.md`](../../docs/THREAT_MODEL.md)
