# Phi‑2 — Model Card (GuardOS)

**Size:** ~2.7B params  
**Best for:** higher-quality text generation, summaries, short code snippets  
**Quantization:** Q4_K_M recommended (GGUF format)

---

## Strengths

- Significantly better output quality than sub‑1B models
- Effective for small secure assistants, summaries, and rewriting tasks
- Can handle code-related prompts with reasonable accuracy

---

## Limits

- Still not a full replacement for 7B+ models — limited reasoning depth
- Slower inference on CPU-only systems
- Tends to overconfidently hallucinate when unsupervised

---

## System requirements

- Q4_K_M quantization strongly recommended for CPU inference
- Minimum: 4GB available RAM, x86_64 CPU (AVX2 preferred)
- Performance acceptable at ≤512 token completions, temperature ~0.6

---

## Use cases in GuardOS

- Can support secure assistant modules when quality matters
- Suggested for use in tools like:
  - GuardPanel (rewrite policies, summarize settings)
  - Hunter (scan or explain suspicious logs or CLI commands)
  - Offline documentation assistants

---

## License

- Source: [Phi‑2 by Microsoft](https://github.com/microsoft/phi-2)
- License: Custom “Phi License”  
- Commercial use may be restricted — verify terms before deployment or redistribution
