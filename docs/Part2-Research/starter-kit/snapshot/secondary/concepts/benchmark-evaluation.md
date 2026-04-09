---
title: Benchmarks and Evaluation Methods
type: concept
sources:
  - "primary/papers/01_Codex_2021.pdf"
  - "primary/papers/02_AlphaCode_2022.pdf"
  - "primary/papers/03_CodeLlama_2023.pdf"
related:
  - "[[codex_summary]]"
  - "[[alphacode_summary]]"
  - "[[codellama_summary]]"
  - "[[sampling-strategies]]"
last_compiled: 2026-04-09
---

## 개요

코드 생성 평가는 BLEU 등 텍스트 유사도 메트릭에서 **functional correctness** (unit test 통과 여부) 중심으로 전환되었다. Codex가 이 전환의 기점.

## 주요 벤치마크

| 벤치마크 | 제안 논문 | 문제 수 | 특징 |
|---------|---------|--------|------|
| **HumanEval** | Codex (2021) | 164 | 수작업 Python 문제, unit test 기반 |
| **MBPP** | Austin et al. (2021) | 974 | 크라우드소싱 Python 문제 |
| **APPS** | Hendrycks et al. (2021) | 10,000 | Intro/Interview/Competition 3단계 |
| **CodeContests** | AlphaCode (2022) | 13,328+ | Codeforces 기반, 시간 분할, 추가 생성 테스트 |
| **MultiPL-E** | Cassano et al. (2023) | HumanEval×18 | HumanEval을 18개 언어로 확장 |

## 평가 메트릭

### pass@k
Codex가 제안한 비편향 추정량:

- k개 샘플 중 하나라도 unit test를 통과하면 문제 해결로 간주
- n개 샘플에서 c개가 정답일 때: pass@k = E[1 - C(n-c,k)/C(n,k)]
- 세 논문 모두 이 메트릭 사용

### 10@k (n@k)
AlphaCode가 도입한 경쟁 프로그래밍 전용 메트릭:

- k개 샘플에서 10개를 선별하여 제출, 하나라도 통과하면 해결
- 필터링과 클러스터링의 효과를 반영

## 벤치마크별 성능 비교 (공통 벤치마크 기준)

### HumanEval pass@1

| 모델 | pass@1 |
|------|--------|
| Codex-12B | 28.81% |
| Codex-S-12B | 37.7% |
| AlphaCode 1B (decoder-only, HumanEval) | ~17% (Appendix C.5) |
| Code Llama 34B | 48.8% |
| Code Llama - Python 70B | **57.3%** |
| Code Llama - Instruct 34B | **67.8%** |

### APPS (Introductory)

| 모델 | 메트릭 | 성능 |
|------|--------|------|
| Codex-12B | 1-shot pass@1 | 4.14% |
| AlphaCode 1B | Filtered 50000 pass@5 | 20.4% |
| Code Llama 34B | pass@5 | 32.8% |

## 핵심 인사이트

1. **BLEU의 한계**: Codex에서 BLEU score가 높은 솔루션이 functional하지 않을 수 있음을 입증 (Figure 8). 이후 모든 코드 생성 연구가 execution-based 평가로 전환.

2. **데이터 오염 문제**: HumanEval은 수작업이라 오염 위험 낮지만, APPS의 일부 문제는 공개 소스에서 유래. CodeContests는 시간 분할로 이를 방지.

3. **False positive 문제**: CodeContests가 추가 테스트 생성으로 false positive를 4%로 감소 (기존 30-60%).

4. **벤치마크 포화 우려**: HumanEval의 164문제가 점차 포화되어, EvoEval 등 진화형 벤치마크가 등장.
