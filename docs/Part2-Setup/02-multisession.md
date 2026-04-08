# 멀티 머신 병렬 작업 완전 가이드

> 로컬 PC + 서버에서 Claude Code 세션 여러 개를 동시에 돌릴 때, 충돌 없이 효율적으로 작업하는 방법
>
> **핵심 조합**: Worktree(작업 격리) + Hook(자동화) + PR(안전한 병합)

---

## 이런 상황에서 필요합니다

로컬 PC와 서버 여러 대에서 각각 Claude Code 세션을 켜놓고 같은 프로젝트를 작업하면:

- **파일 충돌**: 세션 A가 수정 중인 파일을 세션 B가 동시에 덮어씀
- **브랜치 꼬임**: 같은 브랜치에서 여러 세션이 커밋하면 히스토리가 엉킴
- **머지 지옥**: 나중에 합칠 때 대량의 충돌 발생
- **컨텍스트 혼란**: 어떤 세션이 어떤 작업을 했는지 추적 불가

이 문제들을 **Worktree + Hook + PR** 조합으로 해결합니다.

---

## Part A: 핵심 도구 이해하기

### 1. Worktree — 작업 공간 격리

Git worktree는 하나의 `.git` 디렉토리를 공유하면서 **별도의 작업 디렉토리**를 만드는 Git 내장 기능입니다. `git clone`을 여러 번 하는 것과 비슷하지만, `.git`을 공유하니까 훨씬 가볍습니다.

```
my-project/                    ← 메인 작업 디렉토리
├── .git/                      ← 공유되는 Git 저장소 (1개만 존재)
├── .claude/worktrees/
│   ├── frontend/              ← worktree 1 (독립 브랜치 + 독립 파일)
│   ├── backend/               ← worktree 2 (독립 브랜치 + 독립 파일)
│   └── experiment/            ← worktree 3 (독립 브랜치 + 독립 파일)
```

각 worktree는 **독립된 브랜치와 파일 시스템**을 가지므로, 세션 간 파일 충돌이 원천 차단됩니다.

Claude Code는 `--worktree` 플래그로 이를 기본 지원합니다:

```bash
# 이름을 지정하여 worktree 생성 + Claude 세션 시작
claude --worktree frontend

# 다른 터미널에서 별도 worktree 세션
claude --worktree backend

# 이름 없이 실행하면 자동 생성 (예: bright-running-fox)
claude --worktree
```

**중요: Worktree는 로컬 전용입니다.** push/pull로 공유되지 않으며, 각 머신에서 각자 생성합니다. 공유되는 것은 **브랜치**입니다.

### 2. Hook — 자동화

Hook은 "특정 이벤트가 발생하면 자동으로 실행되는 명령"입니다. 낚시 바늘(hook)처럼, 특정 순간에 "낚아채서" 뭔가를 실행합니다.

멀티 세션에서 유용한 Hook:

| Hook | 용도 | 예시 |
|------|------|------|
| **Notification** | 작업 끝나면 알림 | "세션 끝났어!" 팝업 |
| **WorktreeCreate** | worktree 만들 때 자동 설정 | `npm install` 자동 실행 |

### 3. PR (Pull Request) — 안전한 병합

각 worktree에서 작업한 결과를 main 브랜치에 합치는 방법입니다.

```
worktree-frontend ──PR──→ main ←──PR── worktree-backend
                              ←──PR── worktree-experiment
```

PR의 장점:
- 합치기 전에 변경 내용을 한눈에 확인
- 문제가 있으면 합치기 전에 되돌리기 가능
- 어떤 작업이 언제 합쳐졌는지 기록 보존
- Claude에게 `"PR 만들어줘"` 한마디로 생성 가능

---

## Part B: 실전 세팅 (Step by Step)

### 전체 구조

```
           ┌──────────────────────┐
           │  GitHub (원격 저장소)  │
           └───┬───────┬───────┬──┘
               │       │       │
          push/pull  push/pull  push/pull
               │       │       │
         ┌─────┴──┐ ┌──┴─────┐ ┌──┴─────┐
         │로컬 PC  │ │ 서버 1  │ │ 서버 2  │
         │        │ │        │ │        │
         │ wt-1   │ │ wt-3   │ │ wt-4   │
         │ wt-2   │ │        │ │ wt-5   │
         └────────┘ └────────┘ └────────┘

wt = worktree (독립 작업 공간)
```

### 사전 준비

각 머신에 다음이 설치되어 있어야 합니다:

| 도구 | 확인 명령어 | 비고 |
|------|------------|------|
| Git | `git --version` | 2.20 이상 권장 |
| Claude Code | `claude --version` | `--worktree` 플래그 내장 |
| GitHub CLI | `gh --version` | PR 생성용 (선택) |

```bash
# Git 인증 설정 (각 머신에서 한번만)
git config --global credential.helper store
git config --global user.name "내이름"
git config --global user.email "내메일@example.com"
```

---

### Step 1: 프로젝트 초기 설정 (로컬 PC에서 한번만)

#### 1-1. .gitignore 설정

```bash
cd ~/my-project

# worktree 폴더가 git에 추적되지 않도록
echo ".claude/worktrees/" >> .gitignore
git add .gitignore
git commit -m "chore: .gitignore에 worktree 디렉토리 제외"
git push origin main
```

#### 1-2. CLAUDE.md에 역할 분담 기록

Claude Code는 세션 시작 시 `CLAUDE.md`를 자동으로 읽습니다. 여기에 역할을 적어두면 각 세션의 Claude가 **"나는 무슨 역할이다"를 자동으로 인식**합니다.

프로젝트 루트의 `CLAUDE.md`에 추가:

```markdown
## 멀티 세션 역할 분담

| Worktree 이름 | 담당 머신 | 역할 | 담당 파일/폴더 |
|---------------|----------|------|---------------|
| frontend      | 로컬 PC  | UI/프론트엔드 | src/components/, src/pages/ |
| backend       | 서버 1   | API/서버 로직 | src/api/, src/models/ |
| experiment-a  | 서버 2   | 실험 A | experiments/a/ |

### 규칙
- 각 세션은 자기 담당 폴더만 수정할 것
- 공통 파일(package.json 등) 수정 시 main 브랜치에서 직접 작업
- 작업 완료 후 반드시 PR로 합칠 것
```

```bash
git add CLAUDE.md
git commit -m "docs: 멀티 세션 역할 분담 추가"
git push origin main
```

#### 1-3. .worktreeinclude 설정 (선택)

`.env` 같은 환경 파일이 worktree에도 필요하다면:

```bash
cat > .worktreeinclude << 'EOF'
.env
.env.local
config/secrets.json
EOF

git add .worktreeinclude
git commit -m "chore: worktreeinclude 설정"
git push origin main
```

---

### Step 2: Hook 설정 (각 머신에서)

`~/.claude/settings.json`을 편집합니다. Hook은 머신별 로컬 설정이므로 **각 머신에서 개별 설정**해야 합니다.

#### 2-1. 작업 완료 알림

여러 세션을 띄워놓고 다른 일을 하다가, 세션이 끝나면 알림을 받습니다.

**Linux 서버:**

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' '작업 완료! 확인해주세요'"
          }
        ]
      }
    ]
  }
}
```

**Windows 로컬 PC:**

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -Command \"[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude Code 작업 완료!', 'Claude Code')\""
          }
        ]
      }
    ]
  }
}
```

**WSL 환경:**

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -Command \"New-BurntToastNotification -Text 'Claude Code', '작업 완료! 확인해주세요'\""
          }
        ]
      }
    ]
  }
}
```

알림 종류를 필터링하고 싶다면 `matcher`를 변경:

| matcher 값 | 알림 시점 |
|------------|----------|
| `""` (빈 문자열) | 모든 알림 |
| `permission_prompt` | 도구 승인 필요할 때만 |
| `idle_prompt` | 작업 완료 후 대기 중일 때만 |

#### 2-2. Hook 설정 확인

```bash
claude
# 세션 안에서:
/hooks
# → Notification 항목이 보이면 성공
```

---

### Step 3: 서버에서 프로젝트 준비

각 서버에서 프로젝트를 clone하고 Hook을 설정합니다.

**서버 1 (백엔드 담당):**

```bash
# 서버 1에 SSH 접속
ssh user@server1

# 프로젝트 clone
git clone https://github.com/username/my-project.git
cd my-project

# Git 인증 (한번만)
git config --global credential.helper store
git config --global user.name "내이름"
git config --global user.email "내메일@example.com"

# Hook 설정 (Linux)
cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' '[서버1] 작업 완료!'"
          }
        ]
      }
    ]
  }
}
EOF
```

**서버 2 (실험/테스트 담당):**

```bash
# 서버 2에 SSH 접속
ssh user@server2

# 동일하게 clone + 인증 + Hook
git clone https://github.com/username/my-project.git
cd my-project

git config --global credential.helper store
git config --global user.name "내이름"
git config --global user.email "내메일@example.com"

cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' '[서버2] 작업 완료!'"
          }
        ]
      }
    ]
  }
}
EOF
```

Step 1에서 push한 `.gitignore`, `CLAUDE.md`, `.worktreeinclude`가 clone 시 자동으로 포함됩니다.

---

### Step 4: Worktree로 작업 시작

각 머신에서 worktree를 만들고 작업을 시작합니다.

**로컬 PC (프론트엔드 + 문서 작업):**

```bash
cd ~/my-project

# 터미널 1: 프론트엔드 작업
claude -n "프론트작업" --worktree frontend

# 터미널 2: 문서 정리
claude -n "문서정리" --worktree docs-work
```

**서버 1 (백엔드 API):**

```bash
cd ~/my-project

# 백엔드 작업
claude -n "백엔드" --worktree backend
```

**서버 2 (실험 + 테스트):**

```bash
cd ~/my-project

# 터미널 1: 실험 A
claude -n "실험A" --worktree experiment-a

# 터미널 2: 테스트
claude -n "테스트" --worktree test-suite
```

이제 3대의 머신에서 총 5개의 독립 세션이 동시에 돌아갑니다:

```
로컬 PC                서버 1              서버 2
├── frontend           └── backend         ├── experiment-a
└── docs-work                              └── test-suite
```

> **tmux와 함께 쓰면 더 편리!** 한 머신에서 여러 worktree 세션을 한 화면에 배치:
> ```bash
> # tmux 패널 1
> claude --worktree frontend
> # Ctrl+B, % 로 분할 → tmux 패널 2
> claude --worktree docs-work
> ```

> 나중에 `claude --resume "프론트작업"`으로 이어서 작업할 수 있습니다.

---

### Step 5: 작업 중 동기화

#### 내 작업을 리모트에 push

```bash
# worktree 안에서 (Claude에게 시켜도 됨)
git add .
git commit -m "feat: 로그인 UI 구현"
git push origin worktree-frontend
```

또는 Claude에게 직접:
```
커밋하고 push해줘
```

#### 다른 머신의 진행 상황 확인

```bash
git fetch --all
git branch -r                              # 브랜치 목록
git log origin/worktree-backend --oneline -5  # 특정 브랜치 확인
```

#### main 변경사항을 내 worktree에 반영

다른 세션의 작업이 main에 머지된 후:

```bash
git fetch origin
git rebase origin/main
```

---

### Step 6: PR로 작업 합치기

#### PR 생성

Claude에게:
```
PR 만들어줘
```

또는 직접:
```bash
gh pr create --title "feat: 로그인 UI" --body "프론트엔드 로그인 페이지 구현"
```

#### PR 확인 후 머지

```bash
gh pr list          # PR 목록
gh pr view 1        # PR 내용 확인
gh pr merge 1       # 머지
```

#### 머지 순서 권장

충돌을 최소화하려면 **겹치는 파일이 적은 것부터** 머지:

```
1번째: 실험 브랜치 (독립적) → main에 머지
2번째: 백엔드 브랜치 → main에 머지 (rebase 후)
3번째: 프론트엔드 브랜치 → main에 머지 (rebase 후)
```

---

### Step 7: 정리

#### Worktree 정리

```bash
git worktree list                              # 목록 확인
git worktree remove .claude/worktrees/frontend # 삭제
```

> Claude 세션 종료 시에도 변경이 없으면 자동 삭제, 변경이 있으면 유지/삭제 선택이 나옵니다.

#### 머지된 브랜치 정리

```bash
git push origin --delete worktree-frontend  # 리모트 브랜치 삭제
git fetch --prune                           # 로컬 참조 정리
```

---

## Part C: 운영 가이드라인

### 작업 분할 원칙

```
┌─────────────────────────────────────────────┐
│              작업 분할 매트릭스              │
├──────────┬──────────────────────────────────┤
│ 머신     │ 담당 영역                        │
├──────────┼──────────────────────────────────┤
│ 로컬 PC  │ UI/프론트엔드, 문서 작성         │
│ 서버 1   │ 백엔드 API, 데이터베이스          │
│ 서버 2   │ 테스트, CI/CD, 실험              │
└──────────┴──────────────────────────────────┘
```

**핵심: 파일 수준에서 겹치지 않게 분리**

### 전체 워크플로 요약

```
[한번만] 초기 설정
  ├── .gitignore에 .claude/worktrees/ 추가
  ├── CLAUDE.md에 역할 분담 작성
  ├── .worktreeinclude 설정 (선택)
  └── 각 머신에 Hook 설정

[매일 반복] 작업 루프
  ├── 1. claude --worktree <이름> 으로 세션 시작
  ├── 2. 작업 수행 (각자 담당 영역)
  ├── 3. 중간중간 commit + push
  ├── 4. 작업 완료 → PR 생성
  ├── 5. 확인 후 main에 머지
  └── 6. worktree 정리
```

### 주의사항

#### 리소스 관리
- Worktree당 디스크를 추가로 사용 (`.git`은 공유하지만 작업 파일은 별도)
- 대규모 프로젝트에서는 worktree **3~5개가 실용적 상한**
- 미사용 worktree는 주기적으로 정리: `git worktree prune`

#### 런타임 격리 한계
- Worktree는 **파일 시스템만 격리** — 포트, DB, 환경변수는 공유됨
- 각 세션이 같은 포트를 사용하면 충돌 가능
- 필요시 `.env`에서 포트를 worktree별로 다르게 설정

#### origin/HEAD 동기화
- Worktree는 `origin/HEAD`를 기준으로 브랜치를 생성
- 리모트 기본 브랜치가 변경된 경우:

```bash
git remote set-head origin -a
```

---

## 자주 묻는 질문

### Q: Worktree를 만들면 디스크 용량을 많이 쓰나요?
`.git` 폴더는 공유하므로 `git clone`보다 훨씬 가볍습니다. 하지만 작업 파일은 복사되므로 대규모 프로젝트에서는 3~5개가 실용적 상한입니다.

### Q: 두 worktree에서 같은 파일을 수정하면?
작업 중에는 각 worktree가 독립이라 충돌이 없습니다. PR로 합칠 때 충돌이 발생하면 그때 해결합니다. CLAUDE.md에 담당 영역을 명확히 적어두면 예방할 수 있습니다.

### Q: 서버에서 작업하다 로컬에서 이어서 할 수 있나요?
네! 서버에서 commit + push 후, 로컬에서 같은 브랜치를 checkout하면 됩니다:
```bash
git fetch origin
git checkout worktree-backend
claude --continue
```

### Q: Hook 설정이 다른 머신에도 공유되나요?
`~/.claude/settings.json`은 머신 로컬 설정이라 공유되지 않습니다. 각 머신에서 개별 설정해야 합니다. 단, 프로젝트 레벨(`.claude/settings.json`)은 git으로 공유 가능합니다.

### Q: 별도 설치가 필요한가요?
아닙니다! Git(worktree 내장) + Claude Code(`--worktree` 내장) 만 있으면 됩니다. 추가 도구 설치 없이 바로 사용 가능합니다.

### Q: Worktree 대신 다른 방법은 없나요?
있습니다. 간략히 소개하면:
- **머신별 브랜치 분리만** — worktree 없이 `git checkout -b server1/feature` 식으로. 단, 같은 머신에서 여러 세션을 돌리면 파일 충돌 위험
- **GitButler + Hooks** — 단일 디렉토리에서 자동 브랜치 분리. 단, 로컬 전용이라 멀티 머신에 부적합 (실험적 기능)
- **에이전트 팀** — [tmux와 에이전트 팀](./03_Tmux_and_Agent_Teams.md) 참고

---

## 참고 자료

- [Claude Code 공식 문서 — Common Workflows](https://code.claude.com/docs/en/common-workflows)
- [Claude Code Worktree Guide — claudefast](https://claudefa.st/blog/guide/development/worktree-guide)
- [Git Worktrees with Claude Code — Dan Does Code](https://www.dandoescode.com/blog/parallel-vibe-coding-with-git-worktrees)
- [Parallel Claude Code Without Worktrees — GitButler Blog](https://blog.gitbutler.com/parallel-claude-code)
- [ccswitch — Multiple Claude Code Sessions](https://www.ksred.com/building-ccswitch-managing-multiple-claude-code-sessions-without-the-chaos/)
- [incident.io — Shipping Faster with Worktrees](https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees)
