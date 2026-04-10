---
title: "Paper Comparison Table (SSOT)"
type: analysis
sources: [summaries/codex_summary, summaries/alphacode_summary, summaries/codellama_summary]
related: [[outline]]
last_compiled: 2026-04-09
---

# Paper Comparison — Single Source of Truth

> 이 파일이 세 논문 비교의 유일한 진실 공급원(SSOT)입니다.
> main.tex의 테이블은 반드시 이 파일의 수치와 일치해야 합니다.

## 기본 정보

| 항목 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| 저자 | Chen et al. (OpenAI) | Li et al. (DeepMind) | Rozière et al. (Meta AI) |
| 연도 | 2021 | 2022 | 2023 |
| arXiv ID | 2107.03374 | 2203.07814 | 2308.12950 |
| 발표 | arXiv | arXiv (Science 게재) | arXiv |

## 모델 아키텍처

| 항목 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| 아키텍처 | Decoder-only (GPT) | Encoder-decoder (비대칭) | Decoder-only (Llama 2) |
| 모델 크기 | 최대 12B | 300M ~ 41B | 7B, 13B, 34B, 70B |
| 기반 모델 | GPT-3 | From-scratch | Llama 2 |
| 토크나이저 | GPT-3 (공백 최적화) | SentencePiece 8K vocab | BPE (Llama 2 동일) |
| Attention | Standard MHA | Multi-query attention | Grouped-query attention (70B) |

## 학습 전략

| 항목 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| Pre-training 데이터 | GitHub Python 159 GB | GitHub 715.1 GB (다중 언어) | Llama 2 (2T tokens) |
| Code fine-tuning 데이터 | 동일 (GitHub Python) | CodeContests (13,328 문제) | 500B tokens (85% 코드) |
| 추가 특화 | Codex-S (경쟁+CI 문제) | GOLD + tempering + value cond. | Python 100B / Self-Instruct 5B |
| 학습 토큰 | 100B | 354B ~ 1,250B (크기별 다름) | 500B + 100B (Python) |
| 목적 함수 | Standard NTP | NTP + masked LM + GOLD | NTP + FIM (infilling) |
| 공개 여부 | 비공개 | 비공개 | **오픈소스** |

## 추론 전략

| 항목 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| 샘플 수/문제 | ~100 | ~1,000,000 | 1 ~ 100 |
| 샘플링 방법 | Nucleus (p=0.95, T=0.8) | Temperature (T'=0.25) | Nucleus (p=0.95, T=0.8) |
| 선택 전략 | Mean log-prob reranking | 테스트 필터링 → 클러스터링 | Greedy 또는 pass@k |
| 특수 기능 | - | 메타데이터 조건부 생성 | Infilling (FIM), 100K context |

## 벤치마크 성능

### HumanEval (Python, 164 problems)

| 모델 | pass@1 | pass@10 | pass@100 |
|------|--------|---------|----------|
| Codex-12B | 28.81% | 46.81% | 72.31% |
| Codex-S-12B | 37.7% | - | - |
| Code Llama 7B | 33.5% | 59.6% | 85.9% |
| Code Llama 13B | 36.0% | 69.4% | 89.8% |
| Code Llama 34B | 48.8% | 76.8% | 93.0% |
| Code Llama 70B | 53.0% | 84.6% | 96.2% |
| Code Llama - Python 70B | 57.3% | 89.3% | 98.4% |
| Code Llama - Instruct 34B | 67.8% | 90.3% | 97.3% |

> AlphaCode는 HumanEval 주 실험 없음 (Appendix C.5에서 decoder-only 비교만 수행)

### MBPP (Python, 974 problems)

| 모델 | pass@1 | pass@10 | pass@100 |
|------|--------|---------|----------|
| Code Llama 7B | 41.4% | 66.7% | 82.5% |
| Code Llama 34B | 55.0% | 76.2% | 86.6% |
| Code Llama 70B | 62.4% | 81.1% | 91.9% |
| Code Llama - Python 70B | 65.6% | 81.5% | 91.9% |

> Codex, AlphaCode는 MBPP 결과 미보고

### APPS (10,000 problems, 3-tier difficulty)

| 모델 | Introductory | Interview | Competition |
|------|-------------|-----------|-------------|
| Codex-12B (1-shot pass@1) | 4.14% | 0.14% | 0.02% |
| Codex-12B (1-shot pass@1000) | 25.02% | 3.70% | 3.23% |
| AlphaCode 1B (Filtered 50K, pass@5) | 20.4% | 9.7% | 7.8% |
| Code Llama 34B (pass@5) | 32.8% | 8.8% | 2.9% |
| Code Llama 34B (pass@100) | 56.3% | 24.3% | 15.4% |

## 한계 비교

| 한계 | Codex | AlphaCode | Code Llama |
|------|-------|-----------|------------|
| 샘플 효율 | 낮음 (100 샘플 필요) | 극히 낮음 (100만 샘플) | 보통 (1~100) |
| 컨텍스트 길이 | 4,096 tokens | ~2,304 tokens | **100,000 tokens** |
| 복잡한 문제 | 시스템 수준 불가 | 어려운 문제 해결률 낮음 | Intro/Interview 수준 |
| 정렬/안전 | Misalignment 발견 | 미언급 | Red teaming 수행 |
| 재현성 | 불가 (비공개) | 불가 (비공개) | **가능 (오픈소스)** |
