# Step 5: 고급 기능 가이드

이 문서에서는 Claude Code의 **슬래시 명령어, Hooks, MCP 서버, 멀티 에이전트** 등 고급 기능을 안내합니다.

## 1. 슬래시 명령어 (Slash Commands)

Claude Code 내에서 `/`로 시작하는 특수 명령어를 사용할 수 있습니다.

### 1.1 기본 제공 명령어

| 명령어 | 설명 |
|--------|------|
| `/help` | 도움말 및 사용 가능한 명령어 목록 |
| `/init` | CLAUDE.md 자동 생성 |
| `/clear` | 대화 컨텍스트 초기화 |
| `/compact` | 대화 내역 압축 (토큰 절약) |
| `/cost` | 현재 세션의 토큰 사용량 및 비용 확인 |
| `/commit` | 변경사항 분석 후 자동 커밋 |
| `/review` | 코드 리뷰 수행 |
| `/bug` | 버그 리포트 제출 |

### 1.2 커스텀 슬래시 명령어

프로젝트에 맞는 나만의 슬래시 명령어를 만들 수 있습니다.

**설정 방법:**
`.claude/commands/` 디렉토리에 마크다운 파일을 생성합니다.

```
.claude/
└── commands/
    ├── deploy.md
    └── test-all.md
```

**예시: `.claude/commands/deploy.md`**
```markdown
배포 전 체크리스트를 수행합니다:
1. 모든 테스트를 실행하고 통과하는지 확인
2. 빌드가 성공하는지 확인
3. 변경사항을 main 브랜치에 머지
4. 배포 스크립트를 실행
```

이후 Claude Code에서 `/deploy`로 실행할 수 있습니다.

### 1.3 팀 공유 명령어

팀원 모두가 사용할 명령어는 `.claude/commands/` 폴더를 Git에 커밋하여 공유합니다.

## 2. Hooks — 자동화 트리거

Hooks는 Claude Code의 특정 이벤트 발생 시 **셸 명령을 자동으로 실행**하는 기능입니다.

### 2.1 Hook 종류

| Hook | 실행 시점 |
|------|-----------|
| `PreToolUse` | 도구 실행 **전** |
| `PostToolUse` | 도구 실행 **후** |
| `Notification` | 알림 발생 시 |
| `Stop` | Claude 응답 완료 시 |

### 2.2 Hook 설정 예시

`settings.json`에 다음과 같이 설정합니다:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "npm run lint --fix $CLAUDE_FILE_PATH"
      }
    ],
    "Stop": [
      {
        "command": "echo '작업 완료!' | notify-send"
      }
    ]
  }
}
```

위 예시는:
- 파일 편집/생성 후 자동으로 린터 실행
- Claude 응답이 끝나면 데스크톱 알림 전송

## 3. MCP 서버 (Model Context Protocol)

MCP는 Claude Code에 **외부 도구와 데이터 소스를 연결**하는 프로토콜입니다.

### 3.1 MCP 서버 설정

`settings.json`에서 MCP 서버를 등록합니다:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

### 3.2 활용 가능한 MCP 서버 예시

| 서버 | 용도 |
|------|------|
| `server-github` | GitHub 이슈, PR, 리포지토리 조작 |
| `server-filesystem` | 특정 디렉토리의 파일 접근 |
| `server-postgres` | PostgreSQL 데이터베이스 쿼리 |
| `server-slack` | Slack 메시지 전송/읽기 |

## 4. 멀티 에이전트 활용

Claude Code는 복잡한 작업을 **여러 서브 에이전트에 병렬로 위임**할 수 있습니다.

### 4.1 자동 에이전트 분기

Claude Code는 필요에 따라 자동으로 서브 에이전트를 생성합니다:
- **탐색 에이전트**: 코드베이스를 검색하고 분석
- **범용 에이전트**: 복잡한 멀티스텝 작업 수행
- **계획 에이전트**: 구현 전략 수립

### 4.2 Worktree 격리 모드

서브 에이전트를 별도의 Git worktree에서 실행하여 메인 작업 공간에 영향을 주지 않고 작업할 수 있습니다.

```
> 이 리팩토링을 별도 worktree에서 진행해줘
```

## 5. 헤드리스 모드 (Headless / CI 연동)

Claude Code를 CI/CD 파이프라인에서 비대화형으로 실행할 수 있습니다.

```bash
# 단일 프롬프트 실행 (-p 플래그)
claude -p "이 프로젝트의 테스트를 모두 실행하고 결과를 알려줘"

# 파이프로 입력 전달
echo "README.md를 한국어로 번역해줘" | claude

# JSON 출력 모드
claude -p "package.json의 의존성 목록" --output-format json
```

### 5.1 GitHub Actions 예시

```yaml
- name: Claude Code Review
  run: |
    claude -p "이 PR의 변경사항을 리뷰하고 개선점을 코멘트로 남겨줘" \
      --allowedTools Bash,Read,Grep
```

---
> 💡 **Tip:** 커스텀 슬래시 명령어와 Hooks를 조합하면, 프로젝트에 특화된 자동화 워크플로를 구축할 수 있습니다. 예를 들어 `/deploy` 명령 + PostToolUse Hook으로 배포 후 자동 알림을 설정할 수 있습니다.
