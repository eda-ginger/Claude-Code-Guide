# 최종 논문 리스트

> LLM-Based Code Generation 미니 리뷰 — 핵심 3편

선별일: 2026-04-09
수집 소스: arXiv (54편), DBLP (37편) → 중복 제거 후 병합 → 4기준 적용

## 선별 기준

| 기준 | 설명 |
|------|------|
| 높은 인용수 | 영향력이 검증된 핵심 논문 |
| 서로 다른 접근법 | 3편이 각각 다른 축을 대표 |
| 모델 논문 | 새로운 모델을 제안하는 논문 |
| 비교 가능한 벤치마크 | HumanEval, MBPP 등 동일 벤치마크 결과 보유 |

## 최종 3편

| # | Title | Authors | Year | Venue | arXiv ID | Citations | Approach | Benchmark | Source |
|---|-------|---------|------|-------|----------|-----------|----------|-----------|--------|
| 1 | Evaluating Large Language Models Trained on Code (Codex) | Chen et al. | 2021 | arXiv | 2107.03374 | ~10,000+ | Closed-source, GPT fine-tuning, 비공개 데이터 | HumanEval, MBPP | A,B |
| 2 | Competition-Level Code Generation with AlphaCode | Li et al. | 2022 | Science / arXiv | 2203.07814 | ~1,500+ | From-scratch training, 대량 샘플링+필터링 | HumanEval, MBPP, Codeforces | A,B |
| 3 | Code Llama: Open Foundation Models for Code | Rozière et al. | 2023 | arXiv | 2308.12950 | ~3,000+ | Open-source, LLaMA fine-tuning, Infilling | HumanEval, MBPP | A |

## 접근법 다양성

| 축 | Codex | AlphaCode | Code Llama |
|----|-------|-----------|------------|
| 공개 여부 | Closed | Closed | **Open-source** |
| 학습 방식 | Fine-tuning (GPT) | From-scratch pre-training | Fine-tuning (LLaMA) |
| 데이터 전략 | 비공개 GitHub 코드 | 비공개 경쟁 프로그래밍 데이터 | 공개 코드 데이터셋 |
| 추론 전략 | 단일 생성 | 대량 생성 + 필터링/클러스터링 | 단일 생성 + Infilling |
| 특화 영역 | 범용 코드 생성 | 경쟁 프로그래밍 | 범용 + 긴 컨텍스트(100K) |

## 파일 매핑

| # | PDF 파일명 |
|---|-----------|
| 1 | `papers/01_Codex_2021.pdf` |
| 2 | `papers/02_AlphaCode_2022.pdf` |
| 3 | `papers/03_CodeLlama_2023.pdf` |
