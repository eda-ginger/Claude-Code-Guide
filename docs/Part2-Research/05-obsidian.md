# Obsidian으로 연구 관리하기

> 이 문서를 Claude에게 보여주면 LLM-Wiki를 Obsidian 연구 대시보드로 세팅해줍니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Obsidian | 위키 시각화·대시보드 | [obsidian.md](https://obsidian.md/) (무료) |
| 04에서 구축한 위키 | secondary/ 폴더 | `ls secondary/index.md` |

> [LLM-Wiki 지식 베이스](./04-llm-wiki.md)를 먼저 완료하세요. `secondary/`에 요약, 개념 페이지, 비교표, 아웃라인이 있어야 합니다.

## 1. Obsidian에서 프로젝트 열기

`starter-kit/` 폴더 전체를 Obsidian 볼트로 엽니다.

```
Obsidian → 볼트 열기 → docs/Part2-Research/starter-kit 선택
```

열면 바로 `primary/`, `secondary/`, `work_paper/` 폴더가 사이드바에 보입니다. `secondary/`의 마크다운 파일을 클릭하면 논문 요약과 개념 페이지를 읽을 수 있고, `[[wiki-links]]`를 따라 연결된 문서를 탐색할 수 있습니다.

### 필수 플러그인 설치

`설정 → 커뮤니티 플러그인 → 탐색`에서 검색하여 설치합니다:

| 플러그인 | 용도 | 필수 여부 |
|---------|------|----------|
| **Dataview** | 동적 테이블·대시보드 | 필수 |
| **Homepage** | 볼트 열 때 대시보드로 이동 | 필수 |
| **Banners** | 대시보드 상단 배너 | 선택 |

## 2. YAML Frontmatter 표준화

04에서 Ingest할 때 이미 Frontmatter가 들어있지만, Obsidian 대시보드를 활용하려면 **리뷰 상태와 정량 데이터**를 추가해야 합니다. CLAUDE.md에 아래 스키마를 추가하세요:

```yaml
# 논문 요약 페이지 (secondary/summaries/)
---
title: "논문 제목"
type: paper
status: "📋 대기"  # 📋 대기 / 📖 읽는중 / 🔬 분석중 / ✅ 완료
authors: "저자 et al. (소속)"
year: 2023
approach: "접근법 키워드"
dataset: "HumanEval"
performance: 67.8
benchmark: "HumanEval pass@1"
sources:
  - "primary/papers/03_CodeLlama_2023.pdf"
related:
  - "[[fine-tuning]]"
  - "[[benchmark-evaluation]]"
last_compiled: 2026-04-09
---
```

> **주의**: `[[`, `()`, `,` 등 특수문자가 포함된 값은 반드시 따옴표(`"`)로 감싸세요. 인라인 배열(`[a, b]`)은 리스트 형태(`- "a"`)로 작성해야 Dataview가 정상 파싱합니다.

```yaml
# 개념 페이지 (secondary/concepts/)
---
title: "개념 제목"
type: concept
sources:
  - "primary/papers/01_Codex_2021.pdf"
related:
  - "[[연결된_페이지]]"
last_compiled: 2026-04-09
---
```

> Claude에게 "secondary/의 모든 요약 페이지에 위 Frontmatter 스키마를 적용해줘"라고 요청하면 일괄 업데이트됩니다.

## 3. 연구 대시보드 만들기

`secondary/dashboard.md`를 만들어 리뷰 진행 상황을 한눈에 파악합니다.

Claude에게 요청:

```
secondary/dashboard.md를 만들어줘.
- cssclasses: [dashboard] frontmatter 추가
- 리뷰 진행 현황 (status별 논문 목록, Dataview)
- 비교표 동적 생성 (approach, dataset, performance 컬럼)
- 아웃라인 임베드 (![[outline]])
- Figure/Table 계획 목록 (Dataview)
- 최근 업데이트된 페이지 목록
Homepage 플러그인에서 이 파일을 홈으로 설정해줘.
```

### 리뷰 진행 현황

```dataview
TABLE status AS "상태", year AS "연도", approach AS "접근법"
FROM "secondary/summaries"
WHERE type = "paper"
SORT status ASC
```

논문의 status를 `📋 대기 → 📖 읽는중 → 🔬 분석중 → ✅ 완료`로 업데이트하면 대시보드가 실시간으로 반영됩니다.

### 비교표 동적 생성

```dataview
TABLE
    approach AS "접근법",
    dataset AS "벤치마크",
    performance AS "성능(%)"
FROM "secondary/summaries"
WHERE type = "paper" AND performance != null
SORT performance DESC
```

이 Dataview 테이블은 `secondary/paper_comparison.md`(SSOT)를 보완합니다. 논문이 추가되면 Frontmatter만 채우면 자동으로 행이 늘어납니다.

### 아웃라인 미리보기

대시보드에서 `outline.md`를 임베드하면 논문 구조를 바로 확인할 수 있습니다:

```markdown
## 논문 아웃라인
![[outline]]
```

### Figure / Table 계획

04에서 아웃라인에 포함한 Figure·Table 계획도 대시보드에서 한눈에 볼 수 있습니다:

```dataview
TABLE fig_title AS "Figure", fig_section AS "섹션"
FROM "secondary"
WHERE fig_title != null
```

```dataview
TABLE tbl_title AS "Table", tbl_section AS "섹션"
FROM "secondary"
WHERE tbl_title != null
```

이를 위해 `outline.md` Frontmatter에 Figure·Table 메타데이터를 추가합니다:

```yaml
---
title: "아웃라인"
type: outline
fig_title: "Figure 1: ..."
fig_section: "Approaches"
fig_method: "matplotlib"   # TikZ | matplotlib | Mermaid | 직접 그리기
tbl_title: "Table 1: ..."
tbl_section: "Approaches"
---
```

### 대시보드 CSS

```
.obsidian/snippets/dashboard.css를 만들어줘.
- dashboard cssclass 전용 스타일
- Dataview 테이블 깔끔하게
- 호버 효과
```

`설정 → 외형 → CSS 스니펫`에서 토글을 켜면 적용됩니다.

## 4. Graph View로 지식 시각화

Obsidian의 그래프 뷰(`Ctrl+G`)로 논문과 개념의 연결을 시각화합니다.

### 그룹 설정

그래프 뷰 설정(좌측 상단 톱니바퀴)에서 그룹을 추가합니다:

| 그룹 | 쿼리 | 색상 | 의미 |
|------|------|------|------|
| 논문 | `path:secondary/summaries` | 파랑 | 개별 논문 노드 |
| 개념 | `path:secondary/concepts` | 노랑 | 접근법·개념 허브 |
| 비교·아웃라인 | `path:secondary/paper_comparison` | 빨강 | SSOT 문서 |

### 읽는 법

- **큰 허브 노드**: 여러 논문이 공통으로 참조하는 핵심 개념 (예: `[[benchmark-evaluation]]`)
- **고립된 노드**: 다른 문서와 연결되지 않음 → `[[wiki-links]]` 추가 또는 Lint 필요
- **클러스터**: 비슷한 접근법의 논문끼리 뭉침 → 리뷰 논문의 섹션 구분과 대응

> 논문을 추가하고 Ingest할 때마다 그래프가 자동으로 확장됩니다.

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| Dataview 쿼리가 안 나옴 | Dataview 플러그인 활성화 + `설정 → Dataview → Enable JavaScript Queries` |
| Graph View에 노드가 안 보임 | `[[wiki-links]]`가 실제 파일명과 일치하는지 확인 |
| CSS가 적용 안 됨 | `설정 → 외형 → CSS 스니펫`에서 토글 켜기 |
| Frontmatter가 깨져 보임 | `---`로 시작하고 `---`로 닫혀야 함. 들여쓰기 확인 |
| Dataview "No results" | Frontmatter의 `[[...]]`나 괄호가 YAML 파싱을 깨뜨림. 따옴표+리스트 형태로 수정 |
| 대시보드가 자동으로 안 열림 | Homepage 플러그인에서 `secondary/dashboard` 입력 확인 |

---

> 💡 **Tip:** 일상용 대시보드(할 일, 피드, PARA 구조)도 함께 사용하려면 [Gmail 피드 + Obsidian 대시보드](../Part3-Life/02-gmail-feed.md)을 참고하세요. 연구 프로젝트와 일상 관리를 하나의 볼트에서 통합할 수 있습니다.

→ **다음 단계**: 비교표와 아웃라인을 바탕으로 LaTeX 미니 리뷰 논문을 작성합니다 — [학술 논문 쓰기](./06-paper-writing.md)
