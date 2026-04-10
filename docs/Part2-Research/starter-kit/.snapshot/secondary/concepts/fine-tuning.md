---
title: Fine-Tuning Strategies for Code LLMs
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

세 논문 모두 사전학습된 모델을 코드 도메인에 적응시키는 fine-tuning을 핵심 전략으로 사용하지만, 접근 방식이 크게 다르다.

## 접근법 비교

| 측면 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| 기반 모델 | GPT-3 | From-scratch pre-trained | Llama 2 |
| Fine-tuning 데이터 | GitHub Python 159GB | CodeContests 경쟁 프로그래밍 | 500B tokens 코드+NL |
| 추가 fine-tuning | Codex-S (경쟁+CI 문제) | GOLD + tempering + value conditioning | Python 100B / Self-Instruct 5B |
| 목적함수 | Standard NTP loss | GOLD (offline RL) + masked LM | NTP + FIM (infilling) |
| 공개 여부 | 비공개 | 비공개 | **오픈소스** |

## 핵심 인사이트

1. **기반 모델의 중요성**: Code Llama는 Llama 2 → Code Llama 전환으로 Code Llama-Python 7B > Llama 2 70B 달성. 코드 특화 fine-tuning이 모델 크기 30배 차이를 역전시킨다.

2. **도메인 특화 데이터의 가치**: AlphaCode의 CodeContests fine-tuning이 없으면 경쟁 프로그래밍 성능이 극히 낮음 (Table 7: no pre-training 4.5% vs GitHub all languages 12.4%).

3. **다단계 fine-tuning**: Code Llama의 cascade (Llama 2 → code → Python → instruct)가 점진적 특화의 효과를 보여줌.

4. **GOLD vs Standard MLE**: AlphaCode에서 GOLD (offline RL)가 precision 중심 학습을 가능하게 하여, 하나의 정답만 찾으면 되는 경쟁 프로그래밍에 적합.
