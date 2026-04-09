---
title: Open-Source vs Closed-Source Code Models
type: concept
sources:
  - "primary/papers/01_Codex_2021.pdf"
  - "primary/papers/02_AlphaCode_2022.pdf"
  - "primary/papers/03_CodeLlama_2023.pdf"
related:
  - "[[codex_summary]]"
  - "[[alphacode_summary]]"
  - "[[codellama_summary]]"
  - "[[fine-tuning]]"
last_compiled: 2026-04-09
---

## 개요

LLM 코드 생성 모델의 공개 여부는 연구 재현성, 커뮤니티 발전, 산업 적용에 큰 영향을 미친다.

## 공개 수준 비교

| 측면 | Codex (2021) | AlphaCode (2022) | Code Llama (2023) |
|------|-------------|-----------------|------------------|
| 모델 가중치 | 비공개 | 비공개 | **공개** (허용적 라이선스) |
| 학습 데이터 | 비공개 (GitHub) | 부분 공개 (CodeContests) | 비공개 (코드 데이터셋) |
| 벤치마크 | **HumanEval 공개** | **CodeContests 공개** | 기존 벤치마크 활용 |
| API 접근 | OpenAI API → 종료 | 비공개 | 직접 실행 가능 |
| 논문 | arXiv 공개 | arXiv 공개 | arXiv 공개 |

## 핵심 인사이트

1. **벤치마크 공개의 가치**: Codex는 모델은 비공개이지만 HumanEval 벤치마크를 공개함으로써 전체 분야의 발전에 기여. AlphaCode도 CodeContests를 공개.

2. **Code Llama의 전환점**: 오픈소스 모델이 일부 벤치마크에서 클로즈드 모델을 능가하는 시점. Code Llama - Instruct 34B (67.8% HumanEval)가 Codex-S-12B (37.7%)를 크게 능가.

3. **연구 재현성**: Codex와 AlphaCode의 결과는 외부에서 독립적으로 재현 불가. Code Llama는 공개 가중치로 재현 가능.

4. **모델 특화의 민주화**: Code Llama의 공개로 StarCoder, WizardCoder 등 후속 오픈소스 모델의 기반이 됨. Fine-tuning 비용만으로 특화 모델 구축 가능.
