# LLM-Wiki — 논문 지식 베이스 구축

> 이 문서를 Claude에게 보여주면 수집한 5편의 논문을 Karpathy 방식의 지식 베이스로 구축해줍니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 지식 베이스 구축 실행 | `claude --version` |
| 03에서 수집한 산출물 | 논문 PDF 5편 + paper-list.md | `ls primary/papers/` |

> [에이전트 팀 문헌 수집](./03-collection.md)을 먼저 완료하세요. `primary/papers/`에 PDF 5편과 `primary/paper-list.md`가 있어야 합니다.

---

## LLM-Wiki란?

Andrej Karpathy가 제안한 방식입니다. RAG처럼 질의 시점에 원본을 검색하는 것이 아니라, **LLM이 원본을 읽고 구조화된 위키로 컴파일**합니다. 한 번 정리된 지식은 질문할 때마다 다시 처리할 필요 없이, 위키를 읽고 바로 답변합니다.

```
원본 논문 (primary/)  →  LLM이 요약·연결 (Compile)  →  지식 베이스 (secondary/)
                                                          ↓
                                                   질문하면 위키에서 검색 → 답변
                                                          ↓
                                                   좋은 답변은 위키에 다시 저장 (Filing back)
```

핵심: **좋은 분석 결과를 채팅으로 날려버리지 않고, 위키의 새 페이지로 저장하면 지식이 복리로 쌓입니다.**

> 상세 아키텍처(Hooks 자동화, RAG 비교, 코딩 세션 활용)는 [LLM-Wiki 상세 가이드](../Part4-Appendix/08-llm-wiki-full.md)를 참고하세요.

---

## 1. 프로젝트 구조 만들기

01에서 복사한 starter-kit이 이미 3계층 구조를 갖추고 있습니다:

```
my-mini-review/
├── CLAUDE.md                    # [Schema] 위키 규칙 + 학술 프로젝트 규칙
├── primary/                     # [Raw] 읽기 전용 원본 — LLM은 절대 수정 안 함
│   ├── paper-list.md            # 03에서 만든 최종 리스트
│   └── papers/                  # 논문 PDF
│       ├── 01_ModelA_2021.pdf
│       ├── ...
│       └── 05_ModelE_2024.pdf
├── secondary/                   # [Wiki] LLM이 생성·관리하는 지식 베이스
│   ├── index.md                 # 전체 목차 (에이전트 탐색 시작점)
│   ├── log.md                   # 작업 기록 (시간순, append-only)
│   ├── summaries/               # 논문별 요약 페이지
│   ├── concepts/                # 접근법·개념별 통합 페이지
│   ├── paper_comparison.md      # 비교표 (SSOT) — Query에서 생성
│   └── outline.md               # 논문 아웃라인 — Query에서 생성
└── work_paper/                  # 05에서 사용할 LaTeX 집필 공간
    ├── main.tex
    └── references.bib
```

> 03에서 수집한 PDF와 paper-list.md가 이미 `primary/`에 저장되어 있습니다. `primary/`는 **읽기 전용**입니다 — LLM은 읽기만 하고 절대 수정하지 않습니다.

---

## 2. 위키 규칙 작성 (Schema)

`CLAUDE.md`에 LLM이 위키를 어떻게 구성할지 규칙을 적습니다:

```markdown
# CLAUDE.md

## 프로젝트 목적
LLM-Based Code Generation 논문 5편의 지식 베이스를 구축하고,
미니 리뷰 논문 작성을 위한 비교표와 아웃라인을 생성한다.

## 디렉토리 규칙
- `primary/` — 읽기 전용. 절대 수정하지 않는다.
- `secondary/` — LLM이 생성하고 관리한다.
- `secondary/index.md` — 모든 페이지의 목차. Ingest마다 업데이트.
- `secondary/log.md` — 작업 기록. Append-only.
- `work_paper/` — LaTeX 집필 공간. 04 단계에서 사용.

## 위키 페이지 규칙
- 각 페이지 상단에 YAML Frontmatter:
  ```yaml
  title: 페이지 제목
  sources: [참조한 primary/ 파일들]
  related: [[연결된 개념 페이지들]]
  last_compiled: 날짜
  ```
- 논문 간 연결은 [[wiki-links]] 사용
- 모든 주장에 원본 논문 출처 명시

## Ingest 워크플로
1. primary/ 의 논문을 읽는다
2. secondary/summaries/ 에 논문별 요약 페이지를 만든다
3. secondary/concepts/ 에 접근법별 통합 페이지를 만든다
4. secondary/index.md 를 업데이트한다
5. secondary/log.md 에 작업 기록을 남긴다

## Query 워크플로
1. index.md를 먼저 읽고 관련 페이지를 찾는다
2. 답변을 합성한다
3. 좋은 분석 결과는 secondary/에 새 페이지로 저장한다 (filing back)
```

---

## 3. Ingest — 논문을 위키로 컴파일

Claude Code에게 논문을 처리하라고 지시합니다:

```
primary/ 폴더의 논문 5편을 읽고 지식 베이스를 구축해줘.

각 논문마다:
1. secondary/summaries/ 에 요약 페이지를 만들어줘
   (목적, 방법론, 주요 결과, 한계, 핵심 기여를 포함)
2. 논문들의 공통 접근법이나 개념은 secondary/concepts/ 에 통합 페이지로 만들어줘
3. 페이지 간 [[wiki-links]]로 연결해줘
4. secondary/index.md 와 secondary/log.md 를 업데이트해줘

CLAUDE.md의 규칙을 따라줘.
```

완료되면 이런 구조가 됩니다:

```
secondary/
├── index.md
├── log.md
├── summaries/
│   ├── paper1_summary.md      # 각 논문의 요약
│   ├── paper2_summary.md
│   ├── ...
│   └── paper5_summary.md
└── concepts/
    ├── fine-tuning.md          # 접근법별 통합 페이지
    ├── open-source-models.md
    ├── benchmark-evaluation.md
    └── ...
```

---

## 4. Query — 비교표 생성 (Filing Back)

위키가 구축되면, 횡단 비교를 요청하고 **결과를 위키에 다시 저장**합니다. 이것이 Karpathy 방식의 핵심입니다 — 좋은 분석을 채팅에서 날려버리지 않습니다.

### 비교표 (SSOT) 생성

```
secondary/index.md를 읽고, secondary/concepts/ 의 접근법 페이지들을 탐색해줘.
5편의 논문이 각 접근법을 어떻게 적용했는지 횡단 비교해줘.

결과를 아래 형식의 비교표로 만들고,
secondary/paper_comparison.md 에 저장해줘.
index.md 와 log.md 도 업데이트해줘.

| 항목 | Paper 1 | Paper 2 | Paper 3 | Paper 4 | Paper 5 |
|------|---------|---------|---------|---------|---------|
| 접근법 | ... | ... | ... | ... | ... |
| 학습 데이터 | ... | ... | ... | ... | ... |
| 벤치마크 | ... | ... | ... | ... | ... |
| 주요 성능 | ... | ... | ... | ... | ... |
| 한계 | ... | ... | ... | ... | ... |
```

이 비교표가 논문 작성의 **단일 진실 공급원(SSOT)**이 됩니다.

### 아웃라인 생성

```
secondary/paper_comparison.md 와 관련 개념 페이지들을 바탕으로
미니 리뷰 논문의 아웃라인을 작성해줘.

구조:
- Introduction: 코드 생성 분야 개관
- Background: 주요 벤치마크와 평가 방법
- Approaches: 접근법별 비교 분석
- Discussion: 한계와 향후 연구 방향
- Conclusion

secondary/outline.md 에 저장해줘.
index.md 와 log.md 도 업데이트해줘.
```

---

## 5. Lint — 무결성 검사

논문 작성 전에 위키의 건강 상태를 점검합니다:

```
secondary/ 전체를 점검해줘:
- 비교표(SSOT)의 수치와 개별 논문 요약의 수치가 일치하는지
- 끊어진 [[wiki-links]]가 있는지
- 아무 곳에서도 참조되지 않는 고립된 페이지가 있는지
- 인용이 누락된 주장이 있는지
수정 사항이 있으면 알려줘.
```

---

## 최종 산출물

이 단계를 마치면 아래 파일들이 생성됩니다:

| 파일 | 역할 | 다음 단계 |
|------|------|----------|
| `secondary/paper_comparison.md` | 비교표 (SSOT) | 05에서 LaTeX 테이블로 변환 |
| `secondary/outline.md` | 논문 아웃라인 | 05에서 섹션별 집필 가이드 |
| `secondary/summaries/*.md` | 개별 논문 요약 | 05에서 인용 근거로 참조 |
| `secondary/concepts/*.md` | 접근법 통합 페이지 | 05에서 비교 분석 섹션 근거 |

---

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| Ingest 후 concepts/가 비어있음 | 프롬프트에 "접근법별 통합 페이지도 만들어줘" 명시 |
| 비교표 수치가 논문과 다름 | Lint 실행 후 primary/ 원본과 대조 |
| index.md가 업데이트 안 됨 | CLAUDE.md에 "Ingest마다 index.md 업데이트" 규칙 확인 |
| 위키 페이지 간 링크 깨짐 | `[[파일명]]` 형식이 실제 파일명과 일치하는지 확인 |
| 컨텍스트 부족으로 요약 품질 낮음 | 논문을 한 편씩 Ingest (배치보다 품질 높음) |

---

> 💡 **Tip:** Obsidian으로 `secondary/` 폴더를 열면 지식 그래프를 시각적으로 탐색할 수 있습니다. 논문 간 연결이 잘 되어 있는지 한눈에 확인됩니다.

→ **다음 단계**: 비교표와 아웃라인을 바탕으로 미니 리뷰 논문을 작성합니다 — [학술 논문 쓰기](./05-paper-writing.md)
