# Qwen 1.5 – 0.5B — Model Card (GuardOS)

**Size:** ~0.5B params  
**Best for:** routing logic, summaries, short completions  
**Quantization:** Q4_K_M recommended (GGUF format)

---

## Strengths

- Efficient for simple task classification and dispatch
- Can generate short summaries, rephrase commands, or offer lightweight completions
- Low memory footprint makes it a good default for background AI modules

---

## Limits

- Context window is small; not suitable for multi-turn dialogue
- Tends to hallucinate with long or ambiguous prompts
- Should be restricted to short, focused inputs with structure

---

## System requirements

- Optimized for Q4_K_M using llama.cpp or similar runtime
- Minimum: 2GB available RAM, x86_64 CPU with vector instruction support
- Works well for ≤256 token outputs at low temperature

---

## Use cases in GuardOS

- Can be embedded into GuardPanel or Aegis modules for:
  - Prompt routing and intent detection
  - On-device rewriting of security logs or policy texts
  - Evaluation of short instructions or user queries

---

## License

- Source: [Qwen on Hugging Face](https://huggingface.co/Qwen)
- License: Apache‑2.0  
- Always review license terms of the specific release before redistribution
