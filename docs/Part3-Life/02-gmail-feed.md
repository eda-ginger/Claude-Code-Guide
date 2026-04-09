# Gmail 피드 + Obsidian 대시보드

> 이 문서를 Claude에게 보여주면 Gmail 뉴스레터를 자동 수집하고 Obsidian 대시보드에서 한눈에 확인할 수 있는 시스템을 구축해줍니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 실행 환경 | `claude --version` |
| Obsidian | 대시보드·피드 뷰어 | [obsidian.md](https://obsidian.md/) (무료) |
| Gmail MCP | 뉴스레터 읽기 | Claude Code에서 Gmail 접근 가능한 상태 |

## 1. Obsidian 볼트 구조

PARA 메서드 기반으로 볼트를 구성합니다:

```
Vault/
├── CLAUDE.md                     ← Claude Code 규칙
├── 00. Dashboard.md              ← 홈 화면
├── 01. Inbox/
│   ├── weekly/                   ← 주간 노트
│   └── feed/                     ← 뉴스레터 피드
├── 02. Projects/                 ← 진행 중인 연구/업무
├── 03. Areas/                    ← 삶의 영역 (건강, 재정 등)
├── 04. Resources/                ← 지식 저장소
└── 05. Archive/                  ← 비활성 자료
```

> 폴더명 앞에 번호를 붙이면 항상 원하는 순서로 정렬됩니다.

### 필수 플러그인

`설정 → 커뮤니티 플러그인 → 탐색`에서 설치:

| 플러그인 | 용도 |
|---------|------|
| **Dataview** | 동적 쿼리 테이블 |
| **Tasks** | 체크박스 태스크 추적 |
| **Periodic Notes** | 주간 노트 자동 생성 |
| **Homepage** | 볼트 열 때 Dashboard로 이동 |

## 2. Dashboard 만들기

Claude Code에게 요청합니다:

```
00. Dashboard.md를 만들어줘.
- cssclasses: [dashboard] frontmatter 추가
- 이번 주 할 일 (Tasks 플러그인 쿼리)
- 피드 & 뉴스 섹션 (뉴스레터 목록)
- 프로젝트 현황 테이블
- Areas/Resources 그리드 (이모지 + 링크)
- 최근 수정 파일 (Dataview)
```

### Dashboard 핵심 요소

**주간 할 일:**

```markdown
> [!todo]+ 이번 주 할 일
> ```tasks
> not done
> path includes 01. Inbox/weekly
> ```
```

**최근 수정:**

```dataview
TABLE file.mtime as "수정일"
FROM ""
WHERE file.name != "Dashboard"
SORT file.mtime DESC
LIMIT 5
```

### Dashboard CSS

```
.obsidian/snippets/dashboard.css를 만들어줘.
- dashboard cssclass 전용 스타일
- callout별 색상 (todo: 빨강, rocket: 주황)
- Areas/Resources 그리드 테이블: 가운데 정렬, 호버 효과
```

`설정 → 외형 → CSS 스니펫`에서 토글 켜기.

### Homepage 설정

1. `설정 → Homepage`
2. Homepage: `00. Dashboard`
3. Opening Method: `Replace all open notes`

## 3. Gmail 뉴스레터 피드

Gmail MCP를 통해 뉴스레터를 읽고 Obsidian 피드 노트에 자동 정리합니다.

```
Gmail 뉴스레터 → Claude Code (Gmail MCP) → 피드 노트 (.md)
                                          → 주간 노트 (Action Items만)
```

### 추천 뉴스레터

| 카테고리 | 뉴스레터 | Gmail 검색어 | 빈도 |
|---------|---------|-------------|------|
| 경제 | 순살브리핑 | `from:soonsal` | 매일 |
| 경제 | 디그 | `from:dig@mk.co.kr` | 월수금 |
| AI | AlphaSignal | `from:alphasignal` | 매일 |
| AI | Deep Daiv | `from:deepdaiv` | 매주 |
| 건강 | Peter Attia | `from:peterattiamd` | 주간 |

### Gmail 필터 설정

뉴스레터를 라벨로 자동 분류합니다:

1. Gmail 웹 → `설정 → 필터 → 새 필터 만들기`
2. 보낸사람: `from:soonsal OR from:dig@mk.co.kr OR from:uppity`
3. `라벨 적용: 구독/경제` → 저장

### 처리 스크립트

`.scripts/daily-mail.sh`를 만들어 처리 규칙을 정리합니다:

```bash
#!/bin/bash
cat << 'PROMPT'
## Gmail 뉴스레터 처리 규칙

### 검색 대상 (최근 24시간)
- Action 메일: from:교수 OR from:학과사무실, subject에 마감/제출 포함
- 뉴스레터: from:alphasignal, from:soonsal 등
- 무시: 영수증, 프로모션, 광고

### 피드 카드 포맷
피드 노트(01. Inbox/feed/)에 추가:

> [!note]+ 📮 {월/일} ({요일}) 뉴스레터
> **{이모지} {섹터}**
> - [{키워드}] 한 줄 요약

### 규칙
- 뉴스레터별이 아닌 주제별로 통합
- 한 항목 = 한 줄, 중복 제거

### Action Items (주간 노트에 추가)
- 형식: `- [ ] **[마감일]** 발신자 — 내용`
- 뉴스레터는 주간 노트에 넣지 않음
PROMPT
```

실행:

```
daily-mail.sh 규칙대로 오늘 Gmail 뉴스레터 처리해줘
```

## 4. NLM 리서치 피드 (선택)

NotebookLM CLI로 웹 리서치를 수행하고 같은 피드 노트에 통합할 수 있습니다:

```
nlm으로 이번 주 AI 연구 트렌드를 리서치해서
01. Inbox/feed/ 에 카드 형식으로 저장해줘.
```

> nlm 설치는 [NotebookLM CLI 연동](../Part2-Research/02-notebooklm.md)을 참고하세요.

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| Dashboard가 자동으로 안 열림 | Homepage 플러그인에서 `00. Dashboard` 확인 |
| Dataview 쿼리가 안 나옴 | Dataview 활성화 + JavaScript Queries 켜기 |
| Tasks 쿼리가 비어있음 | 주간 노트 경로가 `01. Inbox/weekly/`에 있는지 확인 |
| CSS가 적용 안 됨 | `설정 → 외형 → CSS 스니펫` 토글 켜기 |
| Gmail MCP에서 메일을 못 읽음 | MCP 설정 및 OAuth 인증 상태 확인 |
| 뉴스레터가 검색 안 됨 | Gmail 검색어 확인, 스팸함 확인 |

---

> 💡 **Tip:** 안정적으로 동작하는 것을 확인한 뒤, cron으로 매일 자동 실행할 수 있습니다: `0 0 * * * cd /path/to/vault && claude -p "$(cat .scripts/daily-mail.sh)"`
