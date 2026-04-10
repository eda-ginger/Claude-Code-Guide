---
title: Operation Log
type: log
---

# Operation Log

## 2026-04-09

### Ingest — 논문 3편 위키 컴파일

- **시각**: 2026-04-09
- **작업**: primary/papers/ 논문 3편 → secondary/ 위키 구축
- **생성 파일**:
  - `summaries/codex_summary.md` — Codex (Chen et al., 2021) 요약
  - `summaries/alphacode_summary.md` — AlphaCode (Li et al., 2022) 요약
  - `summaries/codellama_summary.md` — Code Llama (Rozière et al., 2023) 요약
  - `concepts/fine-tuning.md` — Fine-tuning 전략 비교
  - `concepts/sampling-strategies.md` — 샘플링·선택 전략 비교
  - `concepts/benchmark-evaluation.md` — 벤치마크·평가 방법
  - `concepts/open-source-models.md` — 오픈소스 vs 클로즈드 비교
  - `concepts/infilling.md` — 코드 infilling (FIM) 개념
  - `concepts/long-context.md` — 긴 컨텍스트 처리
  - `index.md` — 위키 목차
- **비고**: 3편 모두 PDF 직접 읽기로 요약. 수치는 원본 논문 Table에서 직접 추출.

### Query — 비교표(SSOT) + 아웃라인 생성

- **시각**: 2026-04-09
- **작업**: summaries/ + concepts/ 기반 횡단 분석 → paper_comparison.md, outline.md 생성
- **생성 파일**:
  - `paper_comparison.md` — SSOT 비교표 (기본 정보, 아키텍처, 학습, 추론, 벤치마크, 한계)
  - `outline.md` — 미니 리뷰 아웃라인 (5 섹션, Figure 1 + Table 1 계획)
- **비고**: 수치는 원본 논문 Table에서 직접 추출. Figure 제작 방식으로 matplotlib 선택 (수치 비교 바 차트에 적합).

### Lint — 위키 무결성 검사

- **시각**: 2026-04-09
- **결과**: SSOT 수치 일치 ✓, 인용 누락 없음 ✓
- **수정 사항**:
  - `alphacode_summary.md`: 깨진 링크 `[[encoder-decoder-architecture]]` → `[[fine-tuning]]`으로 수정
  - `index.md`: arxiv.md, dblp.md를 Collection Logs 섹션으로 등록 (고립 해소)

### Obsidian 대시보드 세팅

- **시각**: 2026-04-09
- **작업**: Frontmatter 표준화 + 대시보드 생성 + CSS 스니펫
- **변경 사항**:
  - summaries/*.md: performance를 단일 수치로 변환 (Dataview 호환)
  - `dashboard.md` 생성: Dataview 기반 동적 테이블 7개 (진행 현황, 비교표, Figure/Table 계획 등)
  - `.obsidian/snippets/dashboard.css` 생성: 대시보드 전용 스타일
  - `index.md`에 대시보드 등록
