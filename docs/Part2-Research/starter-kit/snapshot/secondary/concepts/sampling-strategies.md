---
title: Sampling and Selection Strategies
type: concept
sources:
  - "primary/papers/01_Codex_2021.pdf"
  - "primary/papers/02_AlphaCode_2022.pdf"
  - "primary/papers/03_CodeLlama_2023.pdf"
related:
  - "[[codex_summary]]"
  - "[[alphacode_summary]]"
  - "[[codellama_summary]]"
  - "[[benchmark-evaluation]]"
last_compiled: 2026-04-09
---

## 개요

코드 생성에서 "어떻게 생성하느냐"만큼 "생성한 것 중 어떤 것을 선택하느냐"가 중요하다. 세 논문은 각기 다른 샘플링·선택 전략을 사용한다.

## 접근법 비교

| 측면 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| 샘플 수 | ~100/문제 | ~1,000,000/문제 | 1 (greedy) 또는 ~100 |
| 샘플링 방법 | Nucleus (top-p=0.95) | Temperature sampling (T'=0.25) | Nucleus (p=0.95, T=0.8) |
| 선택 전략 | Mean log-prob reranking | 테스트 필터링 → 클러스터링 | 단일 생성 또는 pass@k |
| 제출 수 | 1~100 | **최대 10** | 1~100 |

## 핵심 인사이트

1. **Codex의 reranking**: mean log-probability 기반 선택이 random보다 11.6pp 향상 (Figure 7). 단, oracle (unit test 사용)과의 격차가 크므로 개선 여지가 있다.

2. **AlphaCode의 대량 생성+필터링**: 가장 극단적인 접근. 100만 개 생성 → example test로 99% 필터링 → 클러스터링으로 다양성 확보 → 10개 제출. 필터링+클러스터링 없이는 성능이 flat (Figure 8).

3. **Code Llama의 단순함**: 주로 greedy decoding (pass@1) 또는 소수 샘플 (pass@10, pass@100)에 집중. 모델 자체의 품질에 의존하는 전략.

4. **스케일링 관계**: AlphaCode에서 solve rate는 샘플 수에 대해 log-linear 스케일링 (Figure 6). 더 큰 모델은 같은 solve rate에 도달하기 위해 지수적으로 적은 샘플이 필요.

5. **컴퓨트 트레이드오프**: 모델 학습에 컴퓨트를 쓸 것인가, 추론 시 샘플링에 쓸 것인가? AlphaCode는 후자를, Code Llama는 전자를 극대화.
