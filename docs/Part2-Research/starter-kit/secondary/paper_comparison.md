# Paper Comparison Table

> 3 papers on LLM-based code generation — Single Source of Truth (SSOT)

## Table 1: Summary Comparison

| Aspect | Codex (2021) | AlphaCode (2022) | Code Llama (2023) |
|--------|-------------|-----------------|-------------------|
| **Authors** | Chen et al. (OpenAI) | Li et al. (DeepMind) | Roziere et al. (Meta) |
| **Venue** | arXiv | Science | arXiv |
| **Architecture** | GPT (decoder-only) | Encoder-decoder Transformer | LLaMA 2 (decoder-only) |
| **Base Model** | GPT-3 (12B) | Custom (41B) | LLaMA 2 (7B--70B) |
| **Training Data** | 54M GitHub repos (159GB) | 715GB GitHub code | Publicly available code (500B tokens) |
| **Languages** | Python (primary) | Python, C++ (12 languages) | Python (primary), multi-language |
| **HumanEval pass@1** | 28.8% (Codex-12B) | -- | 53.7% (Code Llama 34B-Python) |
| **HumanEval pass@100** | 72.3% (Codex-12B) | -- | -- |
| **MBPP pass@1** | -- | -- | 56.2% (Code Llama 34B-Python) |
| **Codeforces** | -- | Top 54.3% (est.) | -- |
| **Key Innovation** | pass@k metric + HumanEval benchmark | Massive sampling (1M+) + clustering | Open-source + infilling + 100K context |
| **Open Source** | No (API only) | No | Yes (weights released) |
| **Infilling** | No | No | Yes (FIM training) |
| **Long Context** | 4K tokens | -- | Up to 100K tokens |
| **Instruction Tuning** | No | No | Yes (Instruct variant) |

## Key Observations

1. **Evaluation gap**: No single benchmark covers all three models directly. Codex defined HumanEval; AlphaCode used Codeforces; Code Llama reports both HumanEval and MBPP.
2. **Scaling strategy differs**: Codex scales model size, AlphaCode scales sample count (1M+ candidates), Code Llama scales both model size and context length.
3. **Open-source trend**: From fully closed (Codex, AlphaCode) to fully open (Code Llama), reflecting the broader industry shift.
