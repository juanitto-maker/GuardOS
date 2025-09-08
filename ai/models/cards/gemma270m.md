# Gemma 270M — Model Card (GuardOS)

**Size:** ~0.27B params  
**Best for:** control flows, classification, system-level prompts  
**Quantization:** Q4_K_M recommended (GGUF format)

---

## Strengths

- Very low memory usage; starts fast
- Ideal for short instructions, input validation, classification, and command routing
- Suitable for always-on background tasks and fast decisions

---

## Limits

- Not designed for long-form reasoning or creative generation
- May hallucinate when asked for open-ended or factual content
- Best used with strict system prompts and guardrails

---

## System requirements

- Works well with Q4_K_M quantization
- Minimum: 2GB available RAM, modern x86_64 CPU
- Compatible with llama.cpp or MLC runtime using GGUF format

---

## License

- Source: [Gemma by Google](https://ai.google.dev/gemma)
- License: [Gemma License](https://ai.google.dev/gemma)
- Review terms before redistribution or commercial use
