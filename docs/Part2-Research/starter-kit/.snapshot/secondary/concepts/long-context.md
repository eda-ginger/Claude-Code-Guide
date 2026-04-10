---
title: Long Context for Code Understanding
type: concept
sources:
  - "primary/papers/03_CodeLlama_2023.pdf"
related:
  - "[[codellama_summary]]"
  - "[[infilling]]"
last_compiled: 2026-04-09
---

## 개요

실제 소프트웨어 프로젝트는 수천~수만 줄의 코드로 구성된다. 함수 수준을 넘어 레포지토리 수준의 코드 이해와 생성을 위해서는 긴 컨텍스트 처리가 필수적이다.

## Code Llama의 Long Context Fine-Tuning (LCFT)

- **방법**: RoPE 위치 임베딩의 base period θ를 10,000 → 1,000,000으로 변경
- **학습**: 시퀀스 길이 16,384로 fine-tuning (Llama 2는 4,096)
- **외삽**: 100,000 토큰까지 perplexity 안정적 감소 (Figure 4a)
- **Key retrieval**: 16K 토큰 내 합성 키 검색에서 gpt-3.5-turbo와 비슷한 성능 (Figure 4b)

## 트레이드오프

- **짧은 컨텍스트 성능 저하**: HumanEval pass@1 -0.52pp, MBPP -1.9pp
- Code Llama 팀은 이 비용이 긴 컨텍스트의 이점으로 상쇄된다고 판단하여 모든 모델에 LCFT 적용

## Codex/AlphaCode와의 차이

- Codex: 4,096 토큰 컨텍스트 (GPT-3 기반)
- AlphaCode: 인코더 1,536 + 디코더 768 토큰으로 경쟁 프로그래밍 문제 설명에 집중
- Code Llama: **100K 토큰**으로 전체 파일이나 다중 파일 컨텍스트 처리 가능
