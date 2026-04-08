# Mini Review: LLM-Based Code Generation

> Outline for a short review paper comparing three landmark approaches.

---

## 1. Introduction

- The emergence of LLMs as code generation tools
- From traditional program synthesis to neural code generation
- Scope of this review: three representative approaches (Codex, AlphaCode, Code Llama)
- Research question: How do different design choices (fine-tuning, sampling, open-source) affect code generation capabilities?

## 2. Background

- Code generation task definition
  - Input: natural language description or function signature
  - Output: functionally correct code
- Evaluation methodology
  - pass@k metric (functional correctness via test cases)
  - HumanEval benchmark (164 Python problems)
  - MBPP benchmark (974 crowd-sourced problems)
  - Competitive programming benchmarks (Codeforces)
- Pre-LLM approaches (brief, 1~2 paragraphs)

## 3. Approaches

### 3.1 Codex (Chen et al., 2021)
- Architecture: GPT-based, fine-tuned on GitHub code
- Training data: 54M public GitHub repositories
- Key contribution: HumanEval benchmark + pass@k metric
- Variants: Codex-S (supervised fine-tuning), Codex-D (docstring generation)

### 3.2 AlphaCode (Li et al., 2022)
- Architecture: Encoder-decoder Transformer
- Training: Pre-training on GitHub + fine-tuning on competitive programming
- Key contribution: Massive sampling + filtering + clustering
- Performance: Estimated top 54.3% in Codeforces competitions

### 3.3 Code Llama (Roziere et al., 2023)
- Architecture: LLaMA 2-based, continued training on code
- Variants: Base, Python-specialized, Instruct
- Key contribution: Open-source, long context (100K tokens), infilling
- Size range: 7B, 13B, 34B, 70B parameters

## 4. Comparative Analysis

- Table 1: Summary comparison (model size, data, benchmark results, availability)
- Discussion points:
  - Closed-source vs open-source trade-offs
  - Scaling laws in code generation
  - Evaluation benchmark limitations
  - Training data considerations

## 5. Conclusion

- Summary of findings
- Future directions: multi-language support, reasoning integration, safety
