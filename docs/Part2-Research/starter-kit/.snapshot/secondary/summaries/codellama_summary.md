---
title: "Code Llama: Open Foundation Models for Code"
type: paper
status: "📋 대기"
authors: "Rozière et al. (Meta AI)"
year: 2023
approach: "Llama 2 fine-tuning, open-source, infilling + long context"
dataset: "500B tokens code-heavy (Code Llama) + 100B Python tokens (Code Llama - Python)"
performance: 67.8
benchmark: "HumanEval pass@1 (Instruct 34B)"
sources:
  - "primary/papers/03_CodeLlama_2023.pdf"
related:
  - "[[codex_summary]]"
  - "[[alphacode_summary]]"
  - "[[fine-tuning]]"
  - "[[infilling]]"
  - "[[long-context]]"
  - "[[benchmark-evaluation]]"
last_compiled: 2026-04-09
---

## 목적

Llama 2 기반으로 코드 특화 오픈소스 모델 패밀리를 구축. 완성(completion), 삽입(infilling), 긴 컨텍스트, 명령어 따르기 등 다양한 용도를 하나의 모델 패밀리로 커버.

## 방법론

- **기반 모델**: Llama 2 (7B, 13B, 34B, 70B)
- **학습 파이프라인** (Figure 2):
  1. Llama 2 → Code training (500B tokens, 85% 코드) → **Code Llama**
  2. Code Llama → Python 추가 학습 (100B tokens) → **Code Llama - Python**
  3. Code Llama → Instruction fine-tuning (5B tokens) → **Code Llama - Instruct**
- **Infilling (FIM)**: 7B, 13B, 70B에 적용. Causal masking으로 prefix-suffix-middle 학습
  - 자동회귀 성능 손실 거의 없음 (0.6pp on HumanEval pass@1)
- **Long Context Fine-Tuning (LCFT)**: RoPE θ를 10,000 → 1,000,000으로 변경
  - 4,096 → 100,000 토큰까지 안정적 외삽 (perplexity 감소 지속)
- **Self-Instruct**: Llama 2 70B로 62,000 프로그래밍 질문 생성 → Code Llama 7B로 솔루션+테스트 생성 → ~14,000 필터링된 triplets

## 주요 결과

| 모델 | Size | HumanEval pass@1 | MBPP pass@1 |
|------|------|------------------|-------------|
| Code Llama | 7B | 33.5% | 41.4% |
| Code Llama | 13B | 36.0% | 47.0% |
| Code Llama | 34B | 48.8% | 55.0% |
| Code Llama | 70B | 53.0% | 62.4% |
| Code Llama - Python | 7B | 38.4% | 47.6% |
| Code Llama - Python | 34B | 53.7% | 56.2% |
| Code Llama - Python | 70B | **57.3%** | **65.6%** |
| Code Llama - Instruct | 34B | 67.8% | 62.2% |
| Code Llama - Instruct | 70B | 67.8% | 62.2% |

- Code Llama - Python 7B가 Llama 2 70B를 능가 (모델 특화의 가치)
- 70B가 MultiPL-E에서 모든 공개 모델 능가 (평균 43.5%)
- APPS: Code Llama 34B pass@5=32.8% (Intro), Codex 12B pass@1000=25.0% 능가
- Infilling: MultiPL-E 단일 라인에서 모든 오픈 모델 능가

## 핵심 기여

1. **오픈소스 코드 모델 패밀리**: 허용적 라이선스(연구+상업)로 7B~70B 4가지 크기 공개
2. **3가지 변형**: 범용(Code Llama), Python 특화, 명령어 따르기 — 용도별 선택 가능
3. **Infilling 능력**: FIM으로 코드 삽입(IDE 자동완성)과 docstring 생성 지원
4. **Long Context**: 100K 토큰 컨텍스트로 레포지토리 수준 코드 이해 가능
5. **Self-Instruct**: 인간 주석 없이 자체 생성 데이터로 Instruct 모델 학습

## 한계

- **34B에 FIM 없음**: 34B 모델은 infilling 학습 제외 (사용자 요청에도 불구)
- **LCFT의 짧은 컨텍스트 성능 저하**: HumanEval pass@1 -0.52pp, MBPP -1.9pp
- **self-instruct 한계**: 자동 생성 데이터의 품질 한계
- **안전성**: 이중 의도 프롬프트에 대한 완전한 방어 불가 (red teaming 결과)

## BibTeX

```bibtex
@article{roziere2023code,
  title={Code Llama: Open Foundation Models for Code},
  author={Rozi{\`e}re, Baptiste and Gehring, Jonas and Gloeckle, Fabian and others},
  journal={arXiv preprint arXiv:2308.12950},
  year={2023}
}
```
