# 대학원생의 Obsidian — Claude Code로 지식 관리 시스템 구축하기

> Dashboard · 피드 파이프라인 · 연구 노트까지, Claude Code 하나로 대학원생의 지식 관리 시스템을 구축하는 실전 가이드

이 가이드는 실제 대학원생의 Obsidian 볼트를 Claude Code로 구축한 과정을 재현 가능하게 정리한 것입니다. Dashboard와 NotebookLM 피드는 직접 따라하며 세팅하고, 연구 노트는 구조를 이해한 뒤 자신의 상황에 맞게 응용할 수 있습니다.

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

## 볼트 구조 배경

이 가이드에서는 [PARA 메서드](https://fortelabs.com/blog/para/) 기반의 볼트 구조를 사용합니다. 핵심은 간단합니다:

```
Vault/
├── 00. Dashboard.md          ← 홈페이지 (이 가이드에서 구축)
├── 01. Inbox/
│   ├── weekly/               ← 주간 노트
│   └── feed/                 ← NLM 리서치 피드 (이 가이드에서 구축)
├── 02. Projects/             ← 진행 중인 연구/업무
├── 03. Areas/                ← 삶의 영역 (건강, 재정 등)
├── 04. Resources/            ← 지식 저장소
└── 05. Archive/              ← 비활성 자료
```

> **Tip:** 폴더명 앞에 번호를 붙이면 파일 탐색기에서 항상 원하는 순서로 정렬됩니다. 폴더 구조는 자유롭게 변경하세요 — 중요한 것은 이 가이드에서 만드는 Dashboard와 피드 시스템입니다.

볼트 루트에 `CLAUDE.md`를 만들어 볼트 구조와 규칙을 적어두면, Claude Code가 매 세션마다 자동으로 인식합니다. 작성법은 [프로젝트 설정 가이드](../Part1-Basic/02-project.md)를 참고하세요.

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

## 피드 파이프라인 — NotebookLM으로 자료 수집

NotebookLM CLI(`nlm`)를 사용하면 Claude Code가 웹 리서치를 수행하고, 결과를 Obsidian 피드 노트로 자동 정리합니다. 뉴스레터 구독 없이도 원하는 주제의 최신 자료를 수집할 수 있습니다.

### 개념

```
nlm research (웹 리서치) → Claude Code → 피드 노트 (.md)
```

NotebookLM의 research 기능은 웹에서 소스를 자동 수집하고 요약합니다. Claude Code가 이 결과를 받아 Obsidian callout 카드로 정리하면, 주간 피드가 완성됩니다.

### 사전 준비

nlm CLI 설치가 필요합니다. 자세한 설치 방법은 [NotebookLM CLI 연동 가이드](../Part2-Research/01-notebooklm.md)를 참고하세요.

```bash
# nlm 설치
npm install -g @anthropic-ai/notebooklm-cli

# 로그인 (세션 ~20분)
nlm login
```

### 1단계: 리서치 노트북 준비

```bash
# 노트북 생성 (한 번만)
nlm notebook create "Weekly Feed" --json

# alias 설정 (편의용)
nlm notebook alias <notebook-id> feed
```

> **주의:** nlm 세션은 ~20분 후 만료됩니다. 작업 전 `nlm login` 상태를 확인하세요.

### 2단계: 리서치 실행

Claude Code에게 요청합니다:

```
nlm으로 이번 주 AI 연구 트렌드를 리서치해서 피드 노트에 정리해줘.
- 노트북: feed
- 주제: AI agent, LLM reasoning, drug discovery AI
- 결과를 01. Inbox/feed/ 에 카드 형식으로 저장
```

Claude Code가 수행하는 작업:

1. `nlm research` 로 주제별 웹 리서치 실행
2. 수집된 소스와 요약을 파싱
3. 피드 노트에 callout 카드로 정리

### 3단계: 피드 카드 포맷

피드 노트(`01. Inbox/feed/2026-W15-feed.md`)에 다음 형식으로 저장됩니다:

```markdown
---
tags:
  - feed
cssclasses:
  - feed
status: unread
week: "2026-W15"
---

# 2026-W15 Feed

## 주간 리서치

> [!example]+ 🤖 AI Agent & Reasoning
> - [MCP 확장] Anthropic MCP 프로토콜 — 도구 연동 표준화 동향
> - [추론 성능] OpenAI o3 vs Claude — 수학/코드 벤치마크 비교
> - [멀티에이전트] CrewAI 프레임워크 — 역할 기반 에이전트 협업

> [!note]+ 💊 Drug Discovery AI
> - [DDI 예측] GNN 기반 약물 상호작용 최신 모델 동향
> - [분자 생성] Diffusion 모델의 신약 후보 탐색 적용
```

### 4단계: 피드 스크립트 작성 (선택)

반복 실행을 위해 스크립트로 정리할 수 있습니다:

```bash
#!/bin/bash
# .scripts/weekly-feed.sh
# Claude Code에게 보여줄 주간 피드 생성 규칙

cat << 'PROMPT'
## 주간 피드 생성 규칙

### nlm research 실행
- 노트북: feed (alias)
- 기존 소스 비우고 실행 (매주 초기화)
- 모드: fast (빠른 수집, ~30초)

### 주제 목록
- AI Agent & Reasoning: AI 에이전트, LLM 추론, 프롬프트 엔지니어링
- Drug Discovery AI: DDI 예측, 분자 생성, KG 기반 약물 발견
- (자신의 연구 주제에 맞게 수정)

### 출력
- 파일: 01. Inbox/feed/{YYYY}-W{ww}-feed.md
- 형식: callout 카드 (주제별 그룹)
- 한 항목 = 한 줄, [키워드] 접두사
PROMPT
```

### 5단계: 피드 노트 CSS (선택)

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

### 검증

1. Obsidian에서 `01. Inbox/feed/` 폴더를 확인합니다
2. 피드 노트를 Reading view로 열어 callout 카드가 정상 표시되는지 확인합니다
3. Dashboard의 Feed & News 섹션에서 피드 노트로 링크가 연결되는지 확인합니다

> **Tip:** Gmail MCP를 연동하면 뉴스레터도 같은 피드 노트에 통합할 수 있습니다. 추천 뉴스레터 목록은 [부록](../Part4-Appendix/)을 참고하세요.

---

## 연구 프로젝트 페이지 (가이드)

> 이 섹션은 구현 가이드입니다. 자신의 연구 주제에 맞게 응용하세요.

*(작성 예정)*

---

## LaTeX 결과 → 연구 노트 (가이드)

> LaTeX 프로젝트의 실험 결과를 Obsidian 연구 노트로 환류하는 워크플로입니다.

*(작성 예정 — [학술 논문 쓰기](../Part2-Research/04-paper-writing.md) 가이드와 연계)*

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
├── 02. Projects/
│   └── my-research/              ← 연구 프로젝트 노트
├── .obsidian/snippets/
│   ├── dashboard.css             ← Dashboard 스타일
│   ├── feed.css                  ← 피드 카드 스타일
│   └── wide-layout.css           ← 넓은 레이아웃
└── .scripts/
    └── weekly-feed.sh            ← 주간 피드 생성 규칙
```

---

## 다음 단계

- [학술 논문 쓰기](../Part2-Research/04-paper-writing.md) — LaTeX + CLAUDE.md로 논문 작성 (이 가이드의 연구 노트와 연계)
- [NotebookLM CLI 연동](../Part2-Research/01-notebooklm.md) — 주간 피드에 NLM 리서치 결과 통합
- [k-skill](./02-k-skill.md) — 미세먼지, SRT 예매 등 한국 생활 스킬 추가
