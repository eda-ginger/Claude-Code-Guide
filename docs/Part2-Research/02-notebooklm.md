# NotebookLM CLI 연동 가이드

> 이 문서를 Claude에게 보여주면 nlm CLI 설치부터 Skill 등록, 기본 사용까지 완성됩니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 실행 환경 | `claude --version` |
| Python 3.8+ | nlm 실행 | `python3 --version` |

NotebookLM CLI(`nlm`)는 Google NotebookLM을 터미널에서 조작하는 도구입니다. MCP 서버 방식도 있지만, **CLI + Skill 조합**이 토큰 효율과 안정성 모두에서 유리합니다.

| 방식 | 토큰 소비 | 안정성 |
|------|----------|--------|
| MCP 서버 | 매 메시지마다 도구 정의 로드 | 좀비 프로세스 가능 |
| **CLI + Skill** | 관련 작업 시에만 로드 | 단순하고 안정적 |

> **주의**: 비공식 API를 사용하므로, 주 계정보다 **보조 Google 계정**을 권장합니다.

## 1. 설치

`uv`(Python 패키지 관리자)로 설치합니다.

```bash
# uv 설치
curl -LsSf https://astral.sh/uv/install.sh | sh

# nlm 설치
uv tool install notebooklm-mcp-cli
```

설치 확인:

```bash
uv --version
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

업그레이드:

```bash
uv tool upgrade notebooklm-mcp-cli

# 버전이 안 올라가면 강제 재설치
uv tool install --force notebooklm-mcp-cli
```

## 2. 인증

```bash
nlm login
```

브라우저가 열리면 Google 계정으로 로그인합니다. 쿠키가 자동으로 추출되어 저장됩니다.

```bash
nlm login --check                    # 인증 상태 확인
nlm login --profile work             # 별도 프로필로 로그인 (여러 계정 사용 시)
nlm login switch <profile>           # 기본 프로필 전환
```

| 구성 요소 | 유효 기간 | 갱신 |
|-----------|-----------|------|
| 쿠키 | 약 2~4주 | 프로필 저장 시 자동 갱신 |
| CSRF 토큰 | 수 분 | 요청 실패 시 자동 갱신 |

> 자동 갱신이 실패하면 `nlm login`을 다시 실행하세요.

## 3. Skill 등록

Skill이 있으면 Claude Code가 NotebookLM 관련 요청을 받을 때 자동으로 `nlm` 명령어 사용법을 참조합니다. 이 저장소를 clone했다면 `.claude/skills/nlm-skill/`에 이미 포함되어 있으므로 **별도 설치 없이 바로 사용 가능**합니다.

다른 프로젝트에서도 사용하려면 아래처럼 설치하세요:

```bash
# 프로젝트 레벨 (해당 프로젝트에서만 사용)
nlm skill install claude-code --level project

# User 레벨 (모든 프로젝트에서 사용)
mkdir -p ~/.claude/skills
nlm skill install claude-code
```

> 프로젝트 레벨과 User 레벨에 **중복 설치하지 마세요.** 하나만 선택하세요.

## 4. 설치 검증

모든 설치가 끝나면 전체 상태를 진단합니다:

```bash
nlm doctor
```

인증, 버전, 연동 상태를 한눈에 확인할 수 있습니다.

## 5. 기본 사용법

### 노트북 관리

```bash
nlm notebook list                          # 목록
nlm notebook create "연구 프로젝트"          # 생성
nlm notebook query <id> "질문"              # 소스에 질문
```

### 소스 추가

```bash
nlm source add <notebook> --url "https://..." --wait       # URL
nlm source add <notebook> --youtube "https://..." --wait   # YouTube
nlm source add <notebook> --file document.pdf --wait       # 파일
```

### 콘텐츠 생성

```bash
nlm report create <notebook> --format "Briefing Doc" --confirm   # 리포트
nlm audio create <notebook> --confirm                            # 오디오
nlm quiz create <notebook> --count 10 --confirm                  # 퀴즈
```

> 전체 명령어는 `nlm --help` 또는 Skill 레퍼런스(`nlm --ai`)를 참고하세요.

## 6. 실전 활용 예시

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

Skill이 설치되어 있으면 자연어로 요청할 수 있습니다.

| 질문 방식 | 예상 결과 |
|-----------|-----------|
| `nlm으로 내 노트북 목록을 보여줘` | `nlm notebook list` 실행 후 목록 출력 |
| `"클라우드 아키텍처" 노트북을 만들고 이 URL들을 소스로 추가해줘` | 노트북 생성 → 소스 추가 순차 실행 |
| `이 YouTube 영상들로 오디오 브리핑을 만들어줘` | 소스 추가 → `nlm audio create` 실행 |
| `"AI 트렌드"에 대해 딥 리서치를 실행하고 브리핑 문서를 생성해줘` | `nlm research start` → `nlm report create` 실행 |

> NotebookLM은 소스에 없는 내용은 생성하지 않으므로 할루시네이션 없이 신뢰할 수 있는 결과를 얻을 수 있습니다.

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| 인증 실패 | `nlm doctor` 실행 → `nlm login --check` 확인 → `nlm login` 재인증 |
| `nlm: command not found` | `export PATH="$HOME/.local/bin:$PATH"`를 `~/.bashrc`에 추가 |
| 버전 업그레이드 안 됨 | `uv tool install --force notebooklm-mcp-cli` |
| 속도 제한 | 무료 티어는 하루 약 50회 쿼리. 시간을 두고 재시도 |
| 쿠키 만료 | 몇 주마다 `nlm login` 재실행 |

### 삭제

```bash
uv tool uninstall notebooklm-mcp-cli         # 패키지 삭제
rm -rf ~/.notebooklm-mcp-cli                 # 인증 토큰 및 데이터 삭제
rm -rf .claude/skills/nlm-skill              # Skill 제거 (프로젝트 레벨)
rm -rf ~/.claude/skills/nlm-skill            # Skill 제거 (User 레벨)
```

---

> 💡 **Tip:** NotebookLM을 집중적으로 쓸 때만 `nlm setup add claude-code`로 MCP를 등록하고, 평소에는 Skill + CLI 조합이 토큰과 안정성 모두에서 효율적입니다.

→ **다음 단계**: 에이전트 팀으로 논문을 수집합니다 — [에이전트 팀 문헌 수집](./03-collection.md)
