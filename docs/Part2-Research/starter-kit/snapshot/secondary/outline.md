---
title: "Mini Review Outline"
type: analysis
sources: [paper_comparison, concepts/fine-tuning, concepts/sampling-strategies, concepts/benchmark-evaluation, concepts/open-source-models]
related: [[paper_comparison]]
last_compiled: 2026-04-09
fig_title: "Figure 1: Evolution of Code Generation Approaches (2021-2023)"
fig_section: "3. Approaches"
fig_method: "matplotlib"
tbl_title: "Table 1: Benchmark Performance Comparison"
tbl_section: "3. Approaches"
tbl_data_source: "paper_comparison.md (SSOT)"
---

# Mini Review Outline

## Title

**From Codex to Code Llama: A Comparative Analysis of LLM-Based Code Generation Approaches**

---

## 1. Introduction (~1 page)

코드 생성 분야의 개관과 본 리뷰의 목적.

- LLM의 등장과 코드 생성에의 적용 배경
- 2021년 Codex 이후 급격한 발전: 클로즈드 → 오픈소스, 함수 수준 → 레포 수준
- 세 논문 선정 이유: 각각 다른 접근법(GPT fine-tuning, 대량 샘플링, 오픈소스 foundation model)
- 본 리뷰의 기여: 접근법 비교, 벤치마크 분석, 향후 방향 제시

## 2. Background (~1 page)

주요 벤치마크와 평가 방법론.

- **벤치마크**: HumanEval (Codex), MBPP, APPS, CodeContests (AlphaCode), MultiPL-E
- **평가 메트릭**: pass@k (비편향 추정량), 10@k (AlphaCode), functional correctness vs BLEU
- **BLEU의 한계**: Codex에서 BLEU가 functional correctness의 좋은 지표가 아님을 입증
- **데이터 오염 문제**: 시간 분할(AlphaCode), 수작업(HumanEval)로 방지

## 3. Approaches (~2-3 pages)

세 논문의 접근법 비교 분석. **이 섹션에 Figure 1과 Table 1이 들어간다.**

### 3.1 Codex: Fine-Tuning GPT for Code
- GPT-3 → GitHub Python fine-tuning → Codex-S (supervised)
- HumanEval 벤치마크 제안, pass@k 메트릭 정의
- Mean log-prob reranking 전략

### 3.2 AlphaCode: Massive Sampling and Filtering
- Encoder-decoder 아키텍처 (비대칭)
- GOLD + tempering 학습
- 대량 생성(100만) → 테스트 필터링 → 클러스터링 → 10개 제출
- 경쟁 프로그래밍에서 최초로 인간 수준 달성

### 3.3 Code Llama: Open Foundation Models
- Llama 2 기반 cascade fine-tuning
- 3가지 변형: Code Llama / Python / Instruct
- Infilling (FIM) + Long Context (100K)
- 오픈소스로 공개, 후속 연구 기반

### 3.4 Comparative Analysis

> **Table 1: Benchmark Performance Comparison**
> - 행: Codex-12B, Codex-S-12B, AlphaCode (various), Code Llama (7B~70B variants)
> - 열: HumanEval pass@1, MBPP pass@1, APPS Introductory
> - 데이터 출처: `paper_comparison.md` SSOT

> **Figure 1: Evolution of Code Generation Approaches (2021-2023)**
> - 내용: 세 모델의 핵심 차이를 시각화하는 비교 다이어그램
>   - X축: 연도 (2021→2022→2023)
>   - 막대: HumanEval pass@1 성능 비교
>   - 주석: 각 모델의 핵심 접근법 라벨
> - 제작 방식: **matplotlib** (수치 비교 바 차트에 적합)
> - 이유: 수치 데이터 비교에 matplotlib이 가장 자연스럽고, LaTeX 내장 TikZ보다 유연하며, 데이터 변경 시 스크립트 재실행만으로 업데이트 가능

## 4. Discussion (~1 page)

한계와 향후 연구 방향.

- **접근법 수렴**: 클로즈드 → 오픈소스, 함수 → 레포 수준으로 수렴
- **샘플 효율성 vs 모델 품질**: AlphaCode의 대량 샘플링 vs Code Llama의 단일 생성 품질
- **컴퓨트 배분**: 학습 컴퓨트 vs 추론 컴퓨트 트레이드오프
- **벤치마크 포화**: HumanEval 164문제의 한계, 진화형 벤치마크(EvoEval) 필요
- **오픈소스의 영향**: Code Llama 이후 오픈소스 생태계 폭발 (StarCoder2, DeepSeek-Coder 등)
- **안전성**: Codex의 misalignment, Code Llama의 red teaming — 코드 생성 특유의 보안 리스크

## 5. Conclusion (~0.5 page)

- 3편이 보여준 세 가지 경로: 데이터 특화 (Codex), 추론 스케일링 (AlphaCode), 모델 공개 (Code Llama)
- 향후: 오픈소스 + 긴 컨텍스트 + 안전성의 삼각 균형
- 코드 생성이 단순 자동완성에서 자율 프로그래밍으로 진화하는 방향

---

## Figure/Table 계획 요약

| 항목 | 제목 | 섹션 | 방식 |
|------|------|------|------|
| Figure 1 | Evolution of Code Generation Approaches (2021-2023) | 3. Approaches | matplotlib (바 차트) |
| Table 1 | Benchmark Performance Comparison | 3. Approaches | paper_comparison.md SSOT에서 추출 |
