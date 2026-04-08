# Gmail 뉴스레터 피드 파이프라인

> Gmail MCP를 연동하여 뉴스레터를 자동으로 읽고 Obsidian 피드 노트에 요약 카드로 정리하는 워크플로

이 가이드는 [대학원생의 Obsidian 볼트](../Part4-Life/01-obsidian-vault.md)의 피드 시스템을 Gmail 뉴스레터로 확장하는 방법을 다룹니다. NotebookLM 피드와 같은 노트에 통합하여, 한 곳에서 모든 정보를 모아볼 수 있습니다.

---

## 개념

```
Gmail 뉴스레터 → Claude Code (Gmail MCP) → 피드 노트 (.md)
                                          → 주간 노트 (Action Items만)
```

- **피드 노트** — 뉴스레터 요약 카드 (읽기 전용)
- **주간 노트** — 행동이 필요한 메일만 (`- [ ] **[마감일]** 발신자 — 내용`)

---

## 사전 준비

- Gmail MCP 연동 완료 (Claude Code에서 Gmail 읽기 가능한 상태)

> **Tip:** Claude Code에서 사용 가능한 MCP 서버 목록은 [Anthropic 공식 문서](https://docs.anthropic.com/en/docs/claude-code/mcp)를 참고하세요.

---

## 추천 뉴스레터

대학원생에게 유용한 뉴스레터를 카테고리별로 정리했습니다.

### 경제/시장 (매일)

| 뉴스레터 | Gmail 검색어 | 내용 | 빈도 |
|---------|-------------|------|------|
| **순살브리핑** | `from:soonsal` | 글로벌 매크로, 월가, 딜 | 매일 |
| **디그** | `from:dig@mk.co.kr` | 한국 경제, 정책 해설 | 월수금 |
| **어피티** | `from:uppity` | 한국 증시, 재테크 | 매일 |
| **The Economist** | `from:economist` | 글로벌 경제, 정치, 시사 | 주간 |

### AI/연구 (매일~주간)

| 뉴스레터 | Gmail 검색어 | 내용 | 빈도 |
|---------|-------------|------|------|
| **AlphaSignal** | `from:alphasignal` | AI 트렌딩 논문/모델 | 매일 |
| **Deep Daiv** | `from:deepdaiv` | AI 기술 심층 해설 (한국어) | 매주 수 |
| **Semantic Scholar** | `from:semanticscholar` | 관심 분야 논문 추천 | 매주 |

> **Tip:** Semantic Scholar는 키워드 구독이 아니라 **논문 Save 기반 추천**입니다. 자신의 연구 분야 논문을 먼저 Save해야 피드가 활성화됩니다.

### 건강/운동 (주간)

| 뉴스레터 | Gmail 검색어 | 내용 | 빈도 |
|---------|-------------|------|------|
| **Peter Attia** | `from:peterattiamd` | 대사건강, 지방간, 수명연장 | 주간 |
| **Stronger by Science** | `from:strongerbyscience` | 근성장, 체성분 연구 | 격주 |

---

## Gmail 필터 설정

뉴스레터가 많아지면 Gmail 필터로 라벨을 자동 분류하는 것을 권장합니다.

### 추천 라벨 구조

```
구독/
├── 경제      ← 순살브리핑, 디그, 어피티, Economist
├── AI        ← AlphaSignal, Deep Daiv, Semantic Scholar
└── 건강      ← Peter Attia, Stronger by Science
```

### 필터 생성 방법

1. Gmail 웹 → `설정 → 필터 및 차단된 주소 → 새 필터 만들기`
2. 보낸사람에 검색어 입력 (예: `from:soonsal OR from:dig@mk.co.kr OR from:uppity`)
3. `라벨 적용: 구독/경제` 선택
4. `일치하는 대화에도 필터 적용` 체크 후 저장

> **Tip:** 여러 뉴스레터를 하나의 필터로 합치면 관리가 편합니다. `from:a OR from:b OR from:c` 형식으로 묶으세요.

---

## 처리 스크립트

Claude Code에게 뉴스레터 처리 규칙을 알려주는 스크립트를 만듭니다:

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
- from:semanticscholar → 논문 추천
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

### Action Items (주간 노트에 추가)
- 형식: `- [ ] **[마감일]** 발신자 — 내용`
- 뉴스레터는 주간 노트에 넣지 않음 — 피드 노트에만
PROMPT
```

### 실행 방법

Claude Code에서:

```
daily-mail.sh 규칙대로 오늘 Gmail 뉴스레터 처리해줘
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
| Gmail MCP에서 메일을 못 읽음 | MCP 설정 및 OAuth 인증 상태 확인 |
| 뉴스레터가 검색 안 됨 | Gmail 검색어(`from:...`) 정확한지 확인, 스팸함 확인 |
| 피드 카드가 중복됨 | 스크립트에 날짜 범위(최근 24시간) 명시 확인 |
| 대학 Gmail에서 앱 비밀번호 생성 불가 | Google Workspace 정책 제한 — 개인 Gmail로 포워딩 설정 |
