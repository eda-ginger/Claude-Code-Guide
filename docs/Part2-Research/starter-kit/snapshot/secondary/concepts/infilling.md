---
title: Code Infilling (Fill-in-the-Middle)
type: concept
sources:
  - "primary/papers/03_CodeLlama_2023.pdf"
  - "primary/papers/01_Codex_2021.pdf"
related:
  - "[[codellama_summary]]"
  - "[[codex_summary]]"
  - "[[fine-tuning]]"
last_compiled: 2026-04-09
---

## 개요

코드 infilling은 주변 컨텍스트(prefix + suffix)가 주어졌을 때 중간 부분을 생성하는 능력이다. IDE의 코드 자동완성, 타입 추론, docstring 생성 등에 핵심적이다.

## Code Llama의 Infilling 접근

- **Fill-in-the-Middle (FIM)** objective: causal masking으로 문서를 prefix, middle, suffix로 분할
- PSM (prefix-suffix-middle) 과 SPM (suffix-prefix-middle) 포맷을 50:50으로 혼합
- 7B, 13B, 70B 모델에 적용 (34B는 제외)
- 자동회귀 성능 손실이 극히 미미: HumanEval pass@1에서 평균 -0.6pp (Table 5)

## Codex와의 비교

Codex는 infilling을 직접 지원하지 않으며, 좌-우 자동회귀(left-to-right)만 지원. 코드 삽입이 필요한 실제 IDE 사용 시나리오에서는 Code Llama가 유리하다.

## 실용적 의의

- **IDE 통합**: 커서 위치에 코드 삽입, 함수 내부 완성
- **Docstring 생성**: 함수 코드가 주어지면 docstring을 중간에 생성
- **타입 추론**: 코드 흐름에서 타입 힌트 삽입
- MultiPL-E 단일 라인 infilling에서 Code Llama 13B가 모든 오픈 모델 능가 (Table 6)
