# 도구 설정

02-project에서 소개한 스킬, MCP, Hook의 실제 설정 방법과 상태 표시줄 설정을 다룹니다.

---

## 1. 스킬 설정

### 커스텀 슬래시 명령 만들기

`.claude/commands/` 디렉토리에 마크다운 파일을 만들면 슬래시 명령이 됩니다.

```
.claude/
└── commands/
    ├── deploy.md      →  /deploy
    └── test-all.md    →  /test-all
```

**예시: `.claude/commands/deploy.md`**

```markdown
배포 전 체크리스트를 수행합니다:
1. 모든 테스트를 실행하고 통과하는지 확인
2. 빌드가 성공하는지 확인
3. 변경사항을 main 브랜치에 머지
4. 배포 스크립트를 실행
```

### 스킬 (고급 명령)

`.claude/skills/` 디렉토리에 에이전트 정의를 포함한 복잡한 워크플로를 만들 수 있습니다. 이 프로젝트의 `/pack`이 스킬의 예시입니다.

```
.claude/
├── commands/    ← 단순 프롬프트 (1파일)
└── skills/      ← 복잡한 워크플로 (에이전트 정의 포함)
    └── session-pack/
        └── SKILL.md
```

### 팀 공유

`.claude/commands/`와 `.claude/skills/` 폴더를 Git에 커밋하면 팀원 모두가 같은 명령어를 사용할 수 있습니다.

---

## 2. MCP 서버 설정

### settings.json에 등록

`~/.claude/settings.json` 또는 `.claude/settings.json`에 MCP 서버를 추가합니다:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    }
  }
}
```

### 자주 쓰이는 MCP 서버

| 서버 | 용도 |
|------|------|
| `server-github` | GitHub 이슈, PR, 리포지토리 |
| `server-filesystem` | 특정 디렉토리 파일 접근 |
| `server-postgres` | PostgreSQL 쿼리 |

### 또는 `/mcp` 명령으로 설정

Claude Code 내에서 `/mcp`를 실행하면 대화형으로 MCP 서버를 추가할 수 있습니다.

---

## 3. Hook 설정

### settings.json에 정의

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

### Hook 종류

| Hook | 실행 시점 | 예시 |
|------|-----------|------|
| `SessionStart` | 세션 시작 시 | 지식 파일 자동 로드 |
| `PreToolUse` | 도구 실행 전 | 위험한 명령 차단 |
| `PostToolUse` | 도구 실행 후 | 린터 자동 실행 |
| `Notification` | 알림 발생 시 | 데스크톱 알림 전송 |
| `Stop` | Claude 응답 완료 시 | 작업 완료 알림 |
| `PreCompact` | 컨텍스트 압축 전 | 대화 요약 저장 |
| `SessionEnd` | 세션 종료 시 | 인수인계 자동 생성 |

### matcher로 특정 도구만 지정

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "echo 'Bash 실행 전 체크'"
      }
    ]
  }
}
```

`matcher`를 생략하면 모든 도구 호출에 대해 실행됩니다.

---

## 4. 헤드리스 모드 (CI/자동화)

Claude Code를 스크립트나 CI/CD에서 비대화형으로 실행할 수 있습니다.

```bash
# 단일 프롬프트 실행
claude -p "이 프로젝트의 테스트를 모두 실행하고 결과를 알려줘"

# JSON 출력
claude -p "package.json의 의존성 목록" --output-format json

# 파이프 입력
echo "README.md를 한국어로 번역해줘" | claude
```

### GitHub Actions 예시

```yaml
- name: Claude Code Review
  run: |
    claude -p "이 PR의 변경사항을 리뷰해줘" \
      --allowedTools Bash,Read,Grep
```

---

## 5. 상태 표시줄 (Status Line)

Claude Code 하단에 컨텍스트 사용량, 비용, Git 상태 등을 실시간으로 표시합니다.

### 가장 간단한 설정

```
> /statusline 모델 이름과 컨텍스트 사용률을 프로그레스 바로 보여줘
```

이 한 줄이면 자동으로 스크립트 생성 + 설정 완료. 상태 표시줄은 로컬에서 실행되므로 API 토큰을 소비하지 않습니다.

> 수동 설정, 예제 스크립트, JSON 필드 목록 등 상세 내용은 [Part4-Appendix/statusline](../Part4-Appendix/01-statusline.md)을 참고하세요.

---

> 💡 **Tip:** 커스텀 슬래시 명령어와 Hook을 조합하면 프로젝트에 특화된 자동화 워크플로를 만들 수 있습니다. 예를 들어 `/deploy` 명령 + PostToolUse Hook으로 배포 후 자동 알림을 설정할 수 있습니다.
