# Gemma 270M — Model Card (GuardOS)

**Size:** ~0.27B params  
**Best for:** control flows, classification, short prompts  
**Quantization:** Q4_K_M recommended

---

## Strengths

- Very small memory use; starts fast
- Good at short instructions, selections, and routing tasks
- Safe default for system prompts and decision trees

---

## Limits

- Weak long-form reasoning
- Not ideal for creative writing or code generation
- Hallucinations possible — wrap with rule-based checks

---

## Android notes

- Runs well on most Android devices with 2GB+ free RAM
- Use low `max_tokens` (≤256) for best latency
- Works smoothly with `llama.cpp` (GGUF Q4_K_M)

---

## License

- Source: [Gemma by Google](https://ai.google.dev/gemma)
- License: [Gemma License](https://ai.google.dev/gemma)
- Check for updates and usage restrictions before deployment
