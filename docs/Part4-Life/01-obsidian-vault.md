# 대학원생의 Obsidian — Claude Code로 지식 관리 시스템 구축하기

> Obsidian 볼트를 PARA 구조로 설계하고, Dashboard · Gmail 피드 파이프라인까지 Claude Code 하나로 구축하는 실전 가이드

이 가이드는 실제 대학원생의 Obsidian 볼트를 Claude Code로 구축한 과정을 재현 가능하게 정리한 것입니다. PARA 구조와 Dashboard는 직접 따라하며 세팅하고, Gmail 피드 파이프라인은 구조를 이해한 뒤 자신의 상황에 맞게 응용할 수 있습니다.

---

## 사전 준비

- Obsidian 설치 완료 (데스크톱)
- Claude Code CLI 설치 완료 ([설치 가이드](../Part1-Basic/01-install.md))
- Obsidian 볼트 폴더에서 `claude` 실행 가능한 상태

### 권장 커뮤니티 플러그인

| 플러그인 | 용도 | 필수 여부 |
|---------|------|----------|
| **Dataview** | 동적 쿼리 테이블 | ✅ 필수 |
| **Tasks** | 체크박스 태스크 추적 | ✅ 필수 |
| **Periodic Notes** | 주간 노트 자동 생성 | ✅ 필수 |
| **Homepage** | 볼트 열 때 Dashboard로 이동 | ✅ 필수 |
| **Banners** | 노트 상단 배너 이미지 | 선택 |
| **Calendar** | 사이드바 캘린더 위젯 | 선택 |

> **Tip:** 커뮤니티 플러그인은 `설정 → 커뮤니티 플러그인 → 탐색`에서 검색하여 설치합니다.

---

## PARA 구조 설계

### PARA란?

Tiago Forte의 정보 정리 프레임워크로, 모든 정보를 4가지 범주로 나눕니다:

| 범주 | 설명 | 예시 |
|------|------|------|
| **P**rojects | 진행 중인 프로젝트 | 논문 작성, 학회 준비 |
| **A**reas | 지속 관리하는 영역 | 건강, 재정, 커리어 |
| **R**esources | 참고 지식 | AI 논문 정리, 코딩 팁 |
| **A**rchive | 비활성 자료 | 완료된 프로젝트 |

### 1단계: 폴더 구조 생성

Claude Code에게 다음과 같이 요청합니다:

```
PARA 구조로 Obsidian 볼트 폴더를 만들어줘.
- 00. Dashboard.md (홈페이지)
- 01. Inbox/ (weekly/ 하위 폴더 포함)
- 02. Projects/
- 03. Areas/
- 04. Resources/
- 05. Archive/
```

생성되는 구조:

```
Vault/
├── 00. Dashboard.md          ← 홈페이지
├── 01. Inbox/
│   └── weekly/               ← 주간 노트
├── 02. Projects/             ← 진행 중인 연구/업무
│   └── _archive/             ← 완료된 프로젝트
├── 03. Areas/                ← 삶의 영역
├── 04. Resources/            ← 지식 저장소
└── 05. Archive/              ← 비활성 자료
```

> **Tip:** 폴더명 앞에 번호(`00.`, `01.`)를 붙이면 Obsidian 파일 탐색기에서 항상 원하는 순서로 정렬됩니다.

### 2단계: CLAUDE.md 작성

볼트 루트에 `CLAUDE.md`를 만들어 Claude Code에게 볼트의 규칙을 알려줍니다. 이 파일이 있으면 Claude Code가 매 세션마다 볼트 구조와 규칙을 자동으로 인식합니다.

```markdown
# Vault Guide for Claude

## Owner
- 이름, 소속, 연구 분야

## Vault Structure (PARA)
00. Dashboard.md
01. Inbox/weekly/    ← 주간 노트 (YYYY-W##.md)
02. Projects/        ← 진행 중인 프로젝트
03. Areas/           ← 삶의 영역 (health, finance, career 등)
04. Resources/       ← 지식 저장소
05. Archive/         ← 비활성 자료

## Naming Convention
- 폴더: lowercase with hyphens (e.g., ddi-survey/)
- 파일: lowercase with hyphens (e.g., review-notes.md)
- 주간 노트: 2026-W15.md
- 내용: 자유 (한국어/영어 혼용)

## Frontmatter Tags
- #project — 프로젝트 노트
- #area — 삶의 영역
- #resource — 지식/레퍼런스
- #weekly — 주간 노트

## When Creating Notes
- 항상 frontmatter tags 포함
- 파일명은 영어 소문자+하이픈
- 새 지식은 04. Resources/ 적절한 하위 폴더에
```

> **핵심:** `CLAUDE.md`는 Claude Code가 프로젝트에 진입할 때 자동으로 읽는 파일입니다. 여기에 볼트 규칙을 적어두면 매번 설명할 필요가 없습니다.

### 3단계: 주간 노트 템플릿 설정

Periodic Notes 플러그인을 설정합니다:

1. `설정 → Periodic Notes → Weekly Note`
2. Format: `gggg-[W]ww`
3. Folder: `01. Inbox/weekly`

주간 노트 구조 예시:

```markdown
---
tags:
  - weekly
week: "2026-W15"
---

# 2026-W15

## Action Items
- [ ] **[04/11]** 지도교수 — 논문 초안 피드백 반영
- [ ] **[04/12]** 학과사무실 — 등록금 납부 확인

## Mon (04/07)
- 랩미팅 발표 준비

## Tue (04/08)
- 논문 리뷰 2편

## Wed ~ Fri
...

## Weekend
...

## End of Week
- 이번 주 요약, 다음 주 이월 사항
```

> **Tip:** `CLAUDE.md`에 주간 노트 규칙을 추가해 두면, Claude Code에게 "이번 주 할 일 정리해줘"라고 말할 때 자동으로 올바른 파일을 찾아 편집합니다.

---

## Dashboard 편성

Dashboard는 볼트의 홈 화면입니다. Dataview 쿼리와 CSS로 한눈에 현황을 파악할 수 있게 만듭니다.

### 1단계: Homepage 플러그인 설정

1. `설정 → Homepage`
2. Homepage: `00. Dashboard`
3. Opening Method: `Replace all open notes`
4. View: `Reading view` (배너 표시를 위해 Reading view 권장)

### 2단계: Dashboard 작성

Claude Code에게 요청합니다:

```
00. Dashboard.md를 만들어줘.
- cssclasses: [dashboard] frontmatter 추가
- 배너 이미지 (Unsplash URL)
- 이번 주 할 일 (Tasks 플러그인 쿼리)
- 프로젝트 현황 테이블
- Areas 그리드 (이모지 + 링크)
- Resources 그리드
- 최근 수정 파일 (Dataview)
```

완성된 Dashboard 구조:

```markdown
---
cssclasses:
  - dashboard
banner: "https://images.unsplash.com/photo-example"
banner_y: 0.4
---

# 📋 Dashboard

---

## 📌 This Week

> [!todo]+ 이번 주 할 일
> ```tasks
> not done
> path includes 01. Inbox/weekly
> filename includes {{date:gggg}}-W{{date:ww}}
> ```

---

## 📰 Feed & News

| 뉴스레터 | 주제 |
|----------|------|
| 순살브리핑 | 글로벌 매크로 |
| AlphaSignal | AI 트렌딩 논문 |
| ... | ... |

---

## 🚀 Projects

| 프로젝트 | 상태 | 노트 |
|---------|------|------|
| [[ddi-survey]] | 🟢 Active | 서베이 논문 |
| [[project-b]] | 🟡 Stalled | ... |

---

## 📂 Areas

| | | | |
|:-:|:-:|:-:|:-:|
| 💼 [[Career]] | 💰 [[Finance]] | 🏃 [[Health]] | 🎯 [[Goals]] |
| 👥 [[Relationships]] | 🎮 [[Hobbies]] | 📸 [[Memories]] | 📬 [[Subscriptions]] |

---

## 📚 Resources

| | | | |
|:-:|:-:|:-:|:-:|
| 🧠 [[AI & ML]] | 🔧 [[Tools]] | 🌏 [[Language]] | 💎 [[Principles]] |

---

> [!clock]- 최근 수정
> ```dataview
> TABLE file.mtime as "수정일"
> FROM ""
> WHERE file.name != "Dashboard"
> SORT file.mtime DESC
> LIMIT 5
> ```
```

### 3단계: Dashboard CSS

Claude Code에게 CSS snippet을 만들어달라고 요청합니다:

```
.obsidian/snippets/dashboard.css를 만들어줘.
- dashboard cssclass 전용 스타일
- callout별 색상 (todo: 빨강, inbox: 파랑, rocket: 주황, book: 초록)
- Areas/Resources 그리드 테이블: 가운데 정렬, 호버 효과
- Dataview 테이블: 작은 폰트
```

핵심 CSS 패턴:

```css
/* Dashboard 전용 — cssclasses: [dashboard] */
.dashboard .callout {
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  transition: transform 0.2s;
}
.dashboard .callout:hover {
  transform: translateY(-1px);
}

/* callout 색상 */
.dashboard .callout[data-callout="todo"] {
  border-left-color: #e74c3c;
}
.dashboard .callout[data-callout="rocket"] {
  border-left-color: #e67e22;
}

/* 그리드 테이블 */
.dashboard table {
  width: 100%;
  text-align: center;
}
.dashboard table a {
  padding: 4px 12px;
  border-radius: 8px;
  transition: transform 0.2s;
}
.dashboard table a:hover {
  transform: translateY(-1px);
}
```

CSS snippet을 활성화합니다:

1. `.obsidian/snippets/` 폴더에 파일 생성
2. `설정 → 외형 → CSS 스니펫` 에서 토글 켜기

> **Tip:** `cssclasses: [dashboard]` 덕분에 이 CSS는 Dashboard에만 적용됩니다. 다른 노트에는 영향 없습니다.

### 4단계: 추가 CSS — Wide Layout

본문 폭이 좁다면 wide-layout snippet을 추가합니다:

```css
/* .obsidian/snippets/wide-layout.css */

/* Reading view 폭 확대 */
.markdown-reading-view .markdown-preview-sizer {
  max-width: 70% !important;
  margin: 0 auto;
}
```

### 검증

1. Obsidian을 재시작합니다
2. 자동으로 Dashboard가 열리는지 확인
3. Reading view에서 배너, callout, 그리드가 정상 표시되는지 확인
4. Tasks 쿼리에 주간 노트의 할 일이 나오는지 확인

---

## Gmail 뉴스레터 피드 파이프라인 (가이드)

> 이 섹션은 구현 가이드입니다. 구조를 이해하고 자신의 상황에 맞게 응용하세요.

### 개념

대학원생이 매일 받는 뉴스레터(논문 알림, 경제 뉴스, AI 트렌드)를 Claude Code가 자동으로 읽고 Obsidian 피드 노트에 요약 카드로 정리합니다.

```
Gmail 뉴스레터 → Claude Code (MCP) → 주간 피드 노트 (.md)
                                    → 주간 노트 (Action Items만)
```

### 아키텍처

```
01. Inbox/
├── weekly/
│   └── 2026-W15.md          ← Action Items (행동 필요한 메일만)
└── feed/
    └── 2026-W15-feed.md     ← 뉴스레터 요약 카드 (전체)
```

**역할 분담:**
- **주간 노트** — 행동이 필요한 메일만 (`- [ ] **[마감일]** 발신자 — 내용`)
- **피드 노트** — 뉴스레터 요약 (읽기 전용, 카드 형식)

### 구현 방법

#### Gmail MCP 연동

Claude Code에서 Gmail을 읽으려면 Gmail MCP가 필요합니다. Claude Code의 MCP 설정에서 Gmail 서버를 추가합니다.

> 💡 **Tip:** Claude Code에서 사용가능한 MCP 서버 목록은 [Anthropic 공식 문서](https://docs.anthropic.com/en/docs/claude-code/mcp)를 참고하세요.

#### 처리 스크립트 작성

`.scripts/daily-mail.sh` 같은 스크립트를 만들어 Claude Code에게 처리 규칙을 알려줍니다:

```bash
#!/bin/bash
# .scripts/daily-mail.sh
# Claude Code에게 보여줄 뉴스레터 처리 규칙

cat << 'PROMPT'
## Gmail 뉴스레터 처리 규칙

### 검색 대상 (최근 24시간)

**Action 메일:**
- from:교수 OR from:학과사무실
- subject에 마감/제출/회신/deadline 포함

**뉴스레터:**
- from:alphasignal → AI 트렌딩 논문
- from:semanticscholar → DDI/KG 논문 추천
- from:soonsal → 글로벌 매크로
- (자신의 구독 목록에 맞게 추가)

**무시:** 영수증, 프로모션, 광고

### 피드 카드 포맷

피드 노트에 다음 형식으로 추가:

> [!note]+ 📮 {월/일} ({요일}) 뉴스레터
> *{뉴스레터 이름들}*
> **{이모지} {섹터}**
> - [{키워드}] 한 줄 요약

### 규칙
- 뉴스레터별이 아닌 주제별로 통합
- 섹터 헤더에 이모지 사용 (🏭 반도체, 🤖 AI, 📈 시장 등)
- 한 항목 = 한 줄, 중복 제거
- 도착하지 않은 뉴스레터는 건너뛰기
PROMPT
```

#### 실행 방법

Claude Code에서:

```
daily-mail.sh 규칙대로 오늘 Gmail 뉴스레터 처리해줘
```

Claude Code가 Gmail MCP로 메일을 검색하고, 피드 노트에 카드를 추가하고, 행동 필요한 메일은 주간 노트 Action Items에 기록합니다.

#### 피드 노트 CSS (선택)

카드에 색상을 입히려면 feed.css snippet을 추가합니다:

```css
/* .obsidian/snippets/feed.css */

/* 피드 페이지 2열 그리드 */
.feed .markdown-preview-sizer > .callout {
  display: inline-block;
  width: calc(50% - 12px);
  vertical-align: top;
}

/* 카드 색상 */
.feed .callout[data-callout="note"] { border-left-color: #3498db; }
.feed .callout[data-callout="example"] { border-left-color: #9b59b6; }
.feed .callout[data-callout="warning"] { border-left-color: #e67e22; }
.feed .callout[data-callout="tip"] { border-left-color: #e74c3c; }
```

### 자동화 (선택)

안정적으로 동작하는 것을 확인한 뒤, cron으로 매일 실행할 수 있습니다:

```bash
# 매일 오전 9시 KST
0 0 * * * cd /path/to/vault && claude -p "$(cat .scripts/daily-mail.sh)"
```

> **주의:** 자동화 전에 2-3일 수동으로 테스트하여 결과물의 품질을 확인하세요.

---

## 트러블슈팅

| 증상 | 해결 방법 |
|------|----------|
| Dashboard가 자동으로 안 열림 | Homepage 플러그인 설정에서 `00. Dashboard` 입력 확인 |
| Dataview 쿼리가 안 나옴 | Dataview 플러그인 활성화 + `설정 → Dataview → Enable JavaScript Queries` 확인 |
| Tasks 쿼리가 비어있음 | 주간 노트 경로가 `01. Inbox/weekly/`에 있는지 확인 |
| CSS가 적용 안 됨 | `설정 → 외형 → CSS 스니펫`에서 해당 snippet 토글 켜기 |
| 배너가 안 보임 | Reading view에서만 표시됨. Live Preview에서는 안 보일 수 있음 |
| `obsidian-git` lock 충돌 | `.git/index.lock` 파일 삭제, auto-commit 간격 30분 이상 권장 |
| Make.md 바이너리 문제 | 비활성화 권장 — `.makemd` 파일이 git 저장소를 비대하게 만듦 |

---

## 전체 구조 요약

```
Vault/
├── CLAUDE.md                     ← Claude Code 규칙
├── 00. Dashboard.md              ← 홈 화면
├── 01. Inbox/
│   ├── weekly/2026-W15.md        ← 주간 노트
│   └── feed/2026-W15-feed.md    ← 뉴스레터 피드
├── 02. Projects/                 ← PARA - Projects
├── 03. Areas/                    ← PARA - Areas
├── 04. Resources/                ← PARA - Resources
├── 05. Archive/                  ← PARA - Archive
├── .obsidian/snippets/
│   ├── dashboard.css             ← Dashboard 스타일
│   ├── feed.css                  ← 피드 카드 스타일
│   └── wide-layout.css           ← 넓은 레이아웃
└── .scripts/
    └── daily-mail.sh             ← Gmail 처리 규칙
```

---

## 다음 단계

- [NotebookLM CLI 연동](../Part3-Research/01-notebooklm.md) — 주간 피드에 NLM 리서치 결과 통합
- [텔레그램 연동](./01-telegram.md) — 외출 중 Claude Code로 볼트 관리
- [k-skill](./03-k-skill.md) — 미세먼지, SRT 예매 등 한국 생활 스킬 추가
