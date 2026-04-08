# 에이전트 팀 문헌 수집

> 이 문서를 Claude에게 보여주면 에이전트 팀으로 논문을 수집하고 핵심 5편을 선별해줍니다.
>
> **예제 주제**: LLM-Based Code Generation 미니 리뷰

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | Agent Teams 실행 | `claude --version` |
| tmux | 팀원 모니터링 | `tmux -V` |
| nlm (NotebookLM CLI) | Deep Research | `nlm login --check` |

> 모든 API는 키 없이 사용 가능합니다. nlm 설치가 안 되어 있다면 [NotebookLM CLI 연동](./02-notebooklm.md)을 먼저 진행하세요.

---

## 1. 수집 기준 정의

논문 수집을 시작하기 전에, **무엇을 찾고 무엇을 제외할지**를 먼저 정의합니다. 제외 기준을 명확히 적어두면 에이전트가 자동 필터링할 때 정확도가 올라갑니다.

```markdown
## Inclusion / Exclusion Criteria

### 포함 (Include)
- LLM 기반 코드 생성 (code generation, code completion, program synthesis)
- 벤치마크 평가 포함 (HumanEval, MBPP 등)
- 연도: 2021 ~ 2026
- 언어: 영어 논문만
- OA(Open Access) 또는 arXiv preprint만
- 인용수가 높은 핵심 논문 우선

### 제외 (Exclude)
- 코드 생성이 아닌 일반 LLM 논문
- 코드 리뷰, 버그 탐지 등 생성이 아닌 태스크
- 유료 저널 (PDF 확보 불가)
- 리뷰/서베이 논문 → 별도 리스트로 분리
```

### 검색 쿼리 설계

에이전트별로 사용할 검색 쿼리를 미리 작성합니다:

```markdown
### arXiv
- cs.CL, cs.SE 카테고리
- "code generation" AND "large language model"
- "program synthesis" AND "benchmark"

### DBLP
- LLM code generation
- code completion large language model
- program synthesis benchmark HumanEval

### NotebookLM Deep Research (2~3개 쿼리)
- "Large language models for code generation: Codex, AlphaCode, CodeLlama comparison"
- "LLM-based code generation benchmarks and evaluation methods 2021-2026"
```

---

## 2. 에이전트 팀 구성

3명의 에이전트가 각각 다른 검색 엔진을 담당합니다. API 키가 필요 없어 바로 시작할 수 있습니다.

```
                    ┌─ [Teammate A: arXiv]      → CS preprint (LLM 논문 대부분 여기)
[Leader/Conductor] ─┼─ [Teammate B: DBLP]       → CS 학회/저널 논문
                    └─ [Teammate C: NotebookLM] → Deep Research 보완 검색
```

| 에이전트 | 검색 엔진 | 강점 | API 키 |
|---------|----------|------|--------|
| A | arXiv API | LLM 논문 대부분 커버, preprint 빠른 반영 | 불필요 |
| B | DBLP API | CS 학회 논문 정확도 높음 (NeurIPS, ICML 등) | 불필요 |
| C | NotebookLM (nlm CLI) | Google 검색 기반, 다른 엔진이 놓친 논문 발견 | 불필요 |

> **규모가 크다면**: Semantic Scholar, PubMed, Google Scholar 에이전트를 추가할 수 있습니다.
> 분야별 추천 구성은 [DDI 대규모 수집 사례](../Part4-Appendix/07-ddi-research.md)를 참고하세요.

---

## 3. 수집 실행

### tmux에서 실행하기

tmux 안에서 Claude Code를 실행하면, 에이전트 팀이 **자동으로 팀원별 분할 창을 생성**합니다.

```bash
# tmux 세션 생성 후 Claude Code 실행
tmux new-session -s research
claude
```

팀을 만들면 자동으로 이렇게 됩니다:

```
┌──────────────────┬──────────────────┐
│  Leader (Claude)  │  Teammate A      │
│                  │  (arXiv)         │
├──────────────────┼──────────────────┤
│  Teammate B      │  Teammate C      │
│  (DBLP)          │  (NotebookLM)    │
└──────────────────┴──────────────────┘
```

> 에이전트 팀 활성화와 tmux 설치는 [세션 활용법](../Part1-Basic/03-session.md)에서 설정합니다.

### 팀 생성 프롬프트

tmux 안에서 Claude Code가 실행된 상태에서, 아래 프롬프트를 전달합니다:

```
논문 수집 팀을 만들어줘. 3명의 팀원이 각각 다른 검색 엔진을 담당해:

- Teammate A (arxiv): arXiv API로 LLM 기반 코드 생성 논문 검색.
  카테고리: cs.CL, cs.SE. 키워드: "code generation", "program synthesis",
  "code completion". 연도 2021~2026 필터.

- Teammate B (dblp): DBLP API로 CS 학회/저널 논문 검색.
  키워드: "LLM code generation", "code completion large language model",
  "program synthesis benchmark".

- Teammate C (nlm): NotebookLM CLI(nlm)로 Deep Research 2~3회 실행.
  쿼리: "LLM-based code generation benchmarks",
  "Codex AlphaCode CodeLlama comparison evaluation"

각 팀원은 결과를 secondary/ 폴더에 자기 파일로 저장해 (secondary/arxiv.md, secondary/dblp.md, secondary/nlm.md).
인용수 정보도 가능하면 함께 수집해줘.
모두 완료되면 나(리더)에게 알려줘. 내가 병합하고 중복 제거할게.
각 팀원은 Sonnet 모델을 사용해.
```

### 각 에이전트의 작동 방식

**Teammate A — arXiv:**

```bash
# https://export.arxiv.org/api/query (반드시 HTTPS)
# search_query=cat:cs.CL+AND+all:"code generation"
# start=0&max_results=50
# 연도 필터는 결과에서 후처리
```

**Teammate B — DBLP:**

```bash
# /search/publ/api?q=LLM+code+generation&format=json&h=100&f=0
# 페이지네이션으로 전체 결과 수집
# venue 필드로 학회/저널 확인
```

**Teammate C — NotebookLM:**

```bash
# 노트북 생성
nlm notebook create "LLM Code Generation Papers"

# Deep Research 실행 (쿼리별)
nlm research start <id> "LLM-based code generation benchmarks"
nlm research start <id> "Codex AlphaCode CodeLlama comparison"

# 결과 리포트 생성
nlm report create <id> --format "Create Your Own" \
  --prompt "모든 소스에서 언급된 개별 논문을 아래 형식의 마크다운 테이블로 나열해줘: | Title | Authors | Year | Venue | DOI | arXiv ID | Citations | Notes |" \
  --confirm
```

### 팀원 간 소통

팀원들은 독립적으로 검색하지만, 리더를 통한 소통으로 수집 품질을 높일 수 있습니다. Agent Teams에서는 **SendMessage**로 팀원↔리더 간 메시지를 주고받고, **공유 Tasks**로 진행 상황을 추적합니다.

**키워드 공유:**

```
Teammate A ──"arXiv에서 'code infilling' 키워드로 관련 논문 3편 추가 발견"
    ──► Leader ──"이 키워드로도 검색해봐"──► Teammate B, C
```

한 에이전트에서 잘 먹힌 키워드를 다른 에이전트에게 공유하면 커버리지가 넓어집니다.

**노이즈 필터 조정:**

```
Teammate B ──"코드 생성이 아닌 코드 요약 논문이 많이 섞여있어"
    ──► Leader ──"제외 기준에 code summarization 추가. 필터 좁혀서 재검색해"
```

검색 중 노이즈가 많으면 리더가 포함/제외 기준을 실시간으로 보완합니다.

**진행 보고:**

```
Teammate A ──"arXiv 완료: 15편"──►
Teammate B ──"DBLP 완료: 8편"───► Leader ──"전원 완료 확인. 병합 시작할게"
Teammate C ──"NLM 완료: 10편"──►
```

### 소통 팁

- **리더를 통한 조율** 권장 — 리더가 전체 그림을 보고 판단하는 게 효율적
- **tmux 분할 창**으로 모든 팀원의 작업을 실시간 모니터링
- 소통이 과하면 오히려 작업이 느려지므로, **큰 발견이 있을 때만** 보고하도록 지시

### 산출물 형식

각 팀원이 동일한 형식으로 결과를 저장합니다:

```markdown
| Title | Authors | Year | Venue | DOI | arXiv ID | Citations | Notes |
|-------|---------|------|-------|-----|----------|-----------|-------|
| Codex | Chen et al. | 2021 | arXiv | - | 2107.03374 | 3000+ | HumanEval 제안 |
| AlphaCode | Li et al. | 2022 | Science | 10.1126/... | 2203.07814 | 800+ | 경쟁 프로그래밍 |
```

---

## 4. 병합 및 5편 선별

리더(또는 사용자)가 팀원의 결과를 취합하고, 미니 리뷰에 사용할 핵심 5편을 선별합니다.

### 중복 제거

```
1. DOI 기준 exact match
2. DOI 없는 경우: 제목 유사도 (fuzzy match, 90%+)
3. 동일 논문이 여러 에이전트에서 발견 → Source에 모두 기재 (예: "A,B,C")
```

### 스코프 필터링

섹션 1에서 정의한 포함/제외 기준을 적용합니다:

```
- Abstract 기반으로 해당 여부 판단
- 경계 케이스는 [?] 플래그 → 사용자 최종 판단
- 서베이 논문은 별도 리스트로 분리
```

### 5편 선별 기준

중복 제거와 스코프 필터링 후, 아래 기준으로 미니 리뷰에 사용할 **핵심 5편**을 선별합니다:

| 기준 | 설명 |
|------|------|
| 인용수 | 인용수가 높은 논문 우선 (영향력 검증) |
| 접근법 다양성 | 서로 다른 접근법을 대표하는 논문 (아래 예시 참고) |
| 벤치마크 | 동일 벤치마크(HumanEval 등)로 비교 가능한 논문 |
| PDF 확보 | arXiv/OA로 PDF를 받을 수 있는 논문 |

접근법이 겹치지 않도록 선별하면, 지식 베이스 정리와 미니 리뷰 비교가 모두 풍부해집니다. 예를 들어 LLM Code Generation 분야라면 이런 축으로 다양성을 확보할 수 있습니다:

| 접근법 축 | 예시 |
|----------|------|
| 학습 방식 | fine-tuning vs. from-scratch pre-training |
| 데이터 전략 | 비공개 데이터 vs. 오픈 데이터셋 |
| 아키텍처 | Dense vs. MoE(Mixture of Experts) |
| 평가 방식 | 단일 함수(HumanEval) vs. 경쟁 프로그래밍 vs. 실무 코드 |
| 공개 여부 | 클로즈드 vs. 오픈소스 |

### 최종 리스트

```markdown
| # | Title | Authors | Year | Venue | arXiv ID | Citations | Approach | Source |
|---|-------|---------|------|-------|----------|-----------|----------|--------|
| 1 | ... | ... | ... | ... | ... | ... | ... | A,C |
| 2 | ... | ... | ... | ... | ... | ... | ... | A,B |
| 3 | ... | ... | ... | ... | ... | ... | ... | A,B,C |
| 4 | ... | ... | ... | ... | ... | ... | ... | A,B |
| 5 | ... | ... | ... | ... | ... | ... | ... | B,C |
```

최종 리스트를 `primary/paper-list.md`에 저장합니다. 이 파일이 이후 지식 베이스 구축과 논문 작성의 입력물이 됩니다.

---

## 5. PDF 확보

선별된 5편은 arXiv/OA 논문이므로 `curl`로 바로 받을 수 있습니다.

```bash
# arXiv 논문
curl -L -o primary/papers/01_ModelName_Year.pdf https://arxiv.org/pdf/<arXiv-ID>.pdf

# OA 저널 — DOI URL에서 직접 다운로드
curl -L -o primary/papers/02_ModelName_Year.pdf <OA-PDF-URL>
```

### 파일 저장 구조

```
primary/
├── paper-list.md
└── papers/
    ├── 01_ModelName_Year.pdf
    ├── 02_ModelName_Year.pdf
    ├── ...
    └── 05_ModelName_Year.pdf
```

파일명 규칙: `{##}_{모델명}_{연도}.pdf` (최종 리스트 번호와 일치)

> PDF는 git에 올리지 않습니다. `.gitignore`에 `primary/papers/*.pdf`를 추가하세요.

---

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| arXiv API 응답 느림 | HTTPS 사용 확인. max_results를 50 이하로 |
| DBLP 검색 결과 0건 | 키워드를 단순화 (예: "code generation"만) |
| nlm Deep Research 실패 | `nlm login --check`로 인증 확인 → `nlm login` 재인증 |
| 중복이 너무 많음 | DOI 기준 제거 후 제목 fuzzy match 추가 |
| PDF 다운로드 실패 | OA가 아닌 유료 논문 → 이 실습에서는 제외 |

---

> 💡 **Tip:** 대규모 수집이 필요하면 [DDI 대규모 수집 사례](../Part4-Appendix/07-ddi-research.md)를 참고하세요. 에이전트 5명 + Playwright 자동 다운로드로 331편을 수집한 실전 사례입니다.

→ **다음 단계**: 수집한 5편으로 지식 베이스를 구축합니다 — [LLM-Wiki](./04-llm-wiki.md)
