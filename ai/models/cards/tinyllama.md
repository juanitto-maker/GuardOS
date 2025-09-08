# TinyLlama 1.1B — Model Card (GuardOS)

**Size:** ~1.1B params  
**Best for:** lightweight chat, prompt routing, guidance tasks  
**Quantization:** Q4_K_M recommended (GGUF format)

---

## Strengths

- Well-tuned for simple chat and guided interactions
- Performs well at routing, filtering, and suggesting next actions
- Small enough for wide deployment on secure personal PCs

---

## Limits

- Not reliable for multi-step reasoning or factual queries
- Hallucinates when pushed beyond short-context tasks
- Combine with system prompts, structured templates, or fallback flows

---

## System requirements

- Ideal for Q4_K_M quantization using llama.cpp or MLC
- Minimum: 3–4GB free RAM, x86_64 CPU with AVX2 support
- Performance improves with batch size 1 and ≤512 max tokens

---

## License

- Source: [TinyLlama on Hugging Face](https://huggingface.co/TinyLlama)
- License: Apache‑2.0  
- Confirm exact version license before redistribution
