# Step 11: NotebookLM CLI 연동 가이드

이 문서에서는 Google NotebookLM을 **터미널에서 CLI로 사용**하고, Claude Code에 **AI Skill로 등록**하여 자연어로 조작하는 방법을 안내합니다.

> 참고: [클로드코드 + 노트북LM = AI 리서치 끝판왕!](https://youtu.be/XiZO5ehF758) (시민개발자 구씨) 영상을 참고하여 작성되었습니다.

---

## 1. NotebookLM CLI란?

[notebooklm-mcp-cli](https://github.com/jacob-bd/notebooklm-mcp-cli)는 Google NotebookLM에 프로그래밍 방식으로 접근할 수 있는 도구입니다. 하나의 패키지로 두 가지를 제공합니다:

| 도구 | 용도 |
|------|------|
| `nlm` (CLI) | 터미널에서 직접 명령어로 NotebookLM 조작 |
| `notebooklm-mcp` (MCP 서버) | AI 어시스턴트(Claude, Cursor 등)에 도구로 연결 |

이 가이드에서는 **CLI + Skill 방식**을 다룹니다.

### CLI, MCP, Skill — 뭐가 다른가?

| | CLI | MCP | Skill |
|---|-----|-----|-------|
| **비유** | 매번 전화를 걸어서 요청 | 비서를 상주시켜 놓는 것 | 비서에게 매뉴얼을 줘서 전화를 대신 걸게 하는 것 |
| **작동** | 명령 실행 → 결과 → 종료 | 서버가 계속 떠 있음 | 필요할 때만 참고 문서 로드 |
| **토큰 소비** | 없음 (직접 실행) | 35개 도구 정의가 **매 메시지마다** 컨텍스트 차지 | 관련 작업 시에만 로드 |
| **안정성** | 단순해서 안정적 | 비공식 서버는 좀비 프로세스, CPU 이슈 가능 | CLI와 동일 |

### 왜 CLI + Skill을 권장하는가?

**CLI + Skill = 두 장점의 조합**입니다:

- Skill은 Claude Code에게 "`nlm` 명령어 사용법"을 알려주는 참고 문서
- Claude가 NotebookLM 관련 요청을 받으면 Skill 문서를 읽고 적절한 CLI 명령어를 대신 실행
- MCP처럼 상시 토큰을 소비하지 않고, 필요할 때만 로드

> 공식 MCP 서버(Notion, Google Calendar 등)는 안정적이지만, 비공식 도구는 CLI 방식이 더 안전합니다.

### 주의사항

- 이 도구는 Google의 **비공식 내부 API**를 사용합니다. API가 예고 없이 변경될 수 있습니다
- 브라우저에서 쿠키를 추출하는 방식으로 인증하므로, **주 계정보다 보조 Google 계정** 사용을 권장합니다
- `nlm`과 NotebookLM 모두 **무료**로 사용 가능합니다

---

## 2. 설치

### 2.1 uv 설치 (패키지 관리자)

`uv`는 Python 도구를 격리된 환경에서 관리하는 빠른 패키지 관리자입니다.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

설치 확인:
```bash
uv --version
```

> `pip`으로도 설치 가능하지만 `uv`를 권장합니다. 도구 격리가 깔끔하고 충돌이 없습니다.

### 2.2 notebooklm-mcp-cli 설치

```bash
uv tool install notebooklm-mcp-cli
```

설치 확인:
```bash
nlm --version
```

<details>
<summary>다른 설치 방법</summary>

```bash
# pip으로 설치
pip install notebooklm-mcp-cli

# pipx로 설치
pipx install notebooklm-mcp-cli

# 설치 없이 바로 실행 (uvx)
uvx --from notebooklm-mcp-cli nlm --help
```
</details>

### 2.3 업그레이드

```bash
uv tool upgrade notebooklm-mcp-cli

# 버전이 안 올라가면 강제 재설치
uv tool install --force notebooklm-mcp-cli
```

---

## 3. 인증 (Google 로그인)

```bash
nlm login
```

브라우저가 열리면 Google 계정으로 로그인합니다. 쿠키가 자동으로 추출되어 저장됩니다.

### 인증 관리

```bash
nlm login --check                    # 인증 상태 확인
nlm login --profile work             # 별도 프로필로 로그인 (여러 계정 사용 시)
nlm login switch <profile>           # 기본 프로필 전환
nlm login profile list               # 모든 프로필 목록
```

### 인증 수명

| 구성 요소 | 유효 기간 | 갱신 |
|-----------|-----------|------|
| 쿠키 | 약 2~4주 | 프로필 저장 시 자동 갱신 |
| CSRF 토큰 | 수 분 | 요청 실패 시 자동 갱신 |
| 세션 ID | 세션 당 | 시작 시 자동 추출 |

> 자동 갱신이 실패하면 `nlm login`을 다시 실행하세요.

---

## 4. Claude Code에 Skill 등록하기

Skill을 설치하면 Claude Code가 NotebookLM 관련 요청을 받을 때 자동으로 `nlm` 명령어 사용법을 참조합니다.

### 프로젝트 레벨 설치 (해당 프로젝트에서만 사용)

```bash
nlm skill install claude-code --level project
```

### User 레벨 설치 (모든 프로젝트에서 사용)

```bash
mkdir -p ~/.claude/skills
nlm skill install claude-code
```

> 프로젝트 레벨과 user 레벨에 **중복 설치하지 마세요.** 하나만 선택하세요.

설치되는 파일:
```
.claude/skills/nlm-skill/
├── SKILL.md                          # 메인 가이드
└── references/
    ├── command_reference.md          # 전체 명령어 레퍼런스
    ├── troubleshooting.md            # 트러블슈팅
    └── workflows.md                  # 워크플로우 예시
```

### Skill 업데이트 / 제거

```bash
# 업데이트
nlm skill update

# 제거
rm -rf .claude/skills/nlm-skill          # 프로젝트 레벨
rm -rf ~/.claude/skills/nlm-skill        # User 레벨
```

---

## 5. 설치 검증

모든 설치가 끝나면 전체 상태를 진단합니다:

```bash
nlm doctor
```

인증, 버전, 연동 상태를 한눈에 확인할 수 있습니다.

---

## 6. CLI 명령어 레퍼런스

`nlm`은 두 가지 명령어 스타일을 지원합니다:

```bash
nlm notebook create "제목"           # 명사 우선 (리소스 중심)
nlm create notebook "제목"           # 동사 우선 (액션 중심)
```

### 노트북

```bash
nlm notebook list                          # 목록
nlm notebook create "연구 프로젝트"          # 생성
nlm notebook get <id>                      # 상세 정보
nlm notebook describe <id>                 # AI 요약
nlm notebook rename <id> "새 제목"          # 이름 변경
nlm notebook delete <id> --confirm         # 삭제 (복구 불가)
nlm notebook query <id> "질문"              # 소스에 질문
```

### 소스

```bash
nlm source list <notebook>                              # 목록
nlm source add <notebook> --url "https://..." --wait    # URL 추가
nlm source add <notebook> --text "내용" --title "메모"    # 텍스트 추가
nlm source add <notebook> --file document.pdf --wait    # 파일 업로드
nlm source add <notebook> --youtube "https://..." --wait # YouTube 추가
nlm source add <notebook> --drive <doc-id>              # Google Drive 문서
```

### 콘텐츠 생성

```bash
# 오디오 (팟캐스트)
nlm audio create <notebook> --confirm
nlm audio create <notebook> --format deep_dive --length long --confirm
# 포맷: deep_dive, brief, critique, debate / 길이: short, default, long

# 비디오
nlm video create <notebook> --format explainer --style classic --confirm

# 리포트
nlm report create <notebook> --format "Briefing Doc" --confirm
# 포맷: "Briefing Doc", "Study Guide", "Blog Post", "Create Your Own"

# 퀴즈 & 플래시카드
nlm quiz create <notebook> --count 10 --difficulty medium --confirm
nlm flashcard create <notebook> --count 20 --difficulty easy --confirm
```

### 다운로드 / 공유 / 도움말

```bash
nlm download audio <notebook> <artifact-id>             # 다운로드
nlm share public <notebook>                             # 공개 링크
nlm share invite <notebook> <email> --role editor       # 편집자 초대

nlm --help              # 전체 명령어 목록
nlm <command> --help    # 특정 명령어 도움말
nlm --ai                # AI 최적화된 전체 문서 (상세)
```

---

## 7. 실전 활용 예시

### 예시 1: YouTube 영상 → 오디오 브리핑

```bash
nlm notebook create "AI 리서치"
nlm source add <notebook-id> --youtube "https://youtube.com/watch?v=..." --wait
nlm source add <notebook-id> --youtube "https://youtube.com/watch?v=..." --wait
nlm audio create <notebook-id> --format brief --confirm
```

### 예시 2: 소스 기반 질의 → 리서치 노트

```bash
nlm source add <notebook-id> --url "https://arxiv.org/..." --wait
nlm source add <notebook-id> --file report.pdf --wait
nlm notebook query <notebook-id> "이 논문들의 핵심 발견을 비교 분석해줘"
nlm report create <notebook-id> --format "Briefing Doc" --confirm
```

> 질의 결과는 NotebookLM 웹 UI 채팅에도 자동으로 기록됩니다.

### 예시 3: 딥 리서치 → PDF 보고서

```bash
nlm research start <notebook-id> "enterprise AI ROI metrics 2026"
nlm source list <notebook-id>
nlm report create <notebook-id> --format "Briefing Doc" --confirm
nlm download report <notebook-id> <artifact-id>
```

### Claude Code에서 자연어로 사용

Skill이 설치되어 있으면 자연어로 요청할 수 있습니다:

```
> nlm으로 내 노트북 목록을 보여줘
> "클라우드 아키텍처" 노트북을 만들고 이 URL들을 소스로 추가해줘
> 이 YouTube 영상들로 오디오 브리핑을 만들어줘
> "AI 트렌드"에 대해 딥 리서치를 실행하고 브리핑 문서를 생성해줘
```

Claude Code는 Skill 문서를 참조하여 적절한 `nlm` 명령어를 실행합니다.

> NotebookLM은 소스에 없는 내용은 생성하지 않으므로 할루시네이션 없이 신뢰할 수 있는 결과를 얻을 수 있습니다.

---

## 8. 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| 인증 실패 | `nlm doctor` 실행 → `nlm login --check` 확인 → `nlm login` 재인증 |
| `nlm: command not found` | `export PATH="$HOME/.local/bin:$PATH"`를 `~/.bashrc`에 추가 |
| 버전 업그레이드 안 됨 | `uv tool install --force notebooklm-mcp-cli` |
| 속도 제한 | 무료 티어는 하루 약 50회 쿼리. 시간을 두고 재시도 |
| 쿠키 만료 | 몇 주마다 `nlm login` 재실행 |

---

## 9. 삭제

```bash
# 패키지 삭제
uv tool uninstall notebooklm-mcp-cli

# 인증 토큰 및 데이터 삭제 (선택)
rm -rf ~/.notebooklm-mcp-cli

# Skill 삭제
rm -rf .claude/skills/nlm-skill          # 프로젝트 레벨
rm -rf ~/.claude/skills/nlm-skill        # User 레벨
```

---
> 💡 **Tip:** NotebookLM을 집중적으로 쓸 때만 `nlm setup add claude-code`로 MCP를 등록하고, 평소에는 Skill + CLI 조합이 토큰과 안정성 모두에서 효율적입니다.
