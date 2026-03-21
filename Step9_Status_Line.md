# Step 9: 상태 표시줄(Status Line) 설정 가이드

이 문서에서는 Claude Code 하단에 표시되는 **커스텀 상태 표시줄**을 설정하여 컨텍스트 사용량, 비용, Git 상태 등을 실시간으로 모니터링하는 방법을 안내합니다.

---

## 1. 상태 표시줄이란?

상태 표시줄은 Claude Code 화면 **하단에 항상 표시되는 커스텀 정보 바**입니다. 셸 스크립트를 실행하여 원하는 정보를 보여줍니다.

**언제 유용한가?**
- 컨텍스트 윈도우 사용량을 작업 중 실시간 확인하고 싶을 때
- 세션 비용을 추적하고 싶을 때
- 여러 세션을 동시에 사용하며 구분이 필요할 때
- Git 브랜치와 상태를 항상 보고 싶을 때

> 상태 표시줄은 **로컬에서 실행**되므로 API 토큰을 소비하지 않습니다.

## 2. 빠른 설정: `/statusline` 명령어

가장 쉬운 방법은 자연어로 원하는 내용을 설명하는 것입니다:

```
> /statusline 모델 이름과 컨텍스트 사용률을 프로그레스 바로 보여줘
```

Claude Code가 자동으로 스크립트 파일을 `~/.claude/`에 생성하고 설정까지 완료합니다.

## 3. 수동 설정 방법

직접 스크립트를 만들고 설정하는 방법입니다.

### 3.1 스크립트 작성

`~/.claude/statusline.sh` 파일을 생성합니다:

```bash
#!/bin/bash
# Claude Code가 stdin으로 보내는 JSON 데이터를 읽기
input=$(cat)

# jq로 필요한 필드 추출 ("// 0"은 null일 때 기본값)
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# 상태 표시줄 출력 — ${DIR##*/}는 폴더명만 추출
echo "[$MODEL] 📁 ${DIR##*/} | ${PCT}% context"
```

### 3.2 실행 권한 부여

```bash
chmod +x ~/.claude/statusline.sh
```

### 3.3 설정 파일에 등록

`~/.claude/settings.json`에 추가합니다:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

> `padding` 옵션으로 좌우 여백을 추가할 수 있습니다 (기본값: 0):
> ```json
> {
>   "statusLine": {
>     "type": "command",
>     "command": "~/.claude/statusline.sh",
>     "padding": 2
>   }
> }
> ```

### 3.4 인라인 명령어로 간단 설정

스크립트 파일 없이 `jq` 한 줄로도 가능합니다:

```json
{
  "statusLine": {
    "type": "command",
    "command": "jq -r '\"[\\(.model.display_name)] \\(.context_window.used_percentage // 0)% context\"'"
  }
}
```

## 4. 작동 원리

1. Claude Code가 **JSON 세션 데이터**를 스크립트의 stdin으로 전달
2. 스크립트가 JSON을 파싱하여 필요한 정보 추출
3. stdout으로 출력한 내용이 상태 표시줄에 표시

**업데이트 시점:**
- 새로운 어시스턴트 메시지가 생성된 후
- 권한 모드가 변경될 때
- Vim 모드가 전환될 때
- 300ms 디바운스 적용 (빠른 변경은 묶어서 한 번만 실행)

## 5. 사용 가능한 데이터 필드

Claude Code가 스크립트에 전달하는 주요 JSON 필드입니다:

### 모델 정보

| 필드 | 설명 |
|------|------|
| `model.id` | 모델 식별자 (예: `claude-opus-4-6`) |
| `model.display_name` | 표시 이름 (예: `Opus`) |

### 작업 공간

| 필드 | 설명 |
|------|------|
| `workspace.current_dir` | 현재 작업 디렉토리 |
| `workspace.project_dir` | Claude Code를 실행한 프로젝트 디렉토리 |

### 비용 및 시간

| 필드 | 설명 |
|------|------|
| `cost.total_cost_usd` | 세션 총 비용 (USD) |
| `cost.total_duration_ms` | 세션 시작 후 경과 시간 (ms) |
| `cost.total_api_duration_ms` | API 응답 대기 시간 합계 (ms) |
| `cost.total_lines_added` | 추가된 코드 줄 수 |
| `cost.total_lines_removed` | 삭제된 코드 줄 수 |

### 컨텍스트 윈도우

| 필드 | 설명 |
|------|------|
| `context_window.context_window_size` | 최대 컨텍스트 크기 (200000 또는 1000000) |
| `context_window.used_percentage` | 사용률 (%) |
| `context_window.remaining_percentage` | 남은 비율 (%) |
| `context_window.total_input_tokens` | 세션 누적 입력 토큰 |
| `context_window.total_output_tokens` | 세션 누적 출력 토큰 |

### 속도 제한 (Claude.ai 구독자만)

| 필드 | 설명 |
|------|------|
| `rate_limits.five_hour.used_percentage` | 5시간 창 사용률 (0~100) |
| `rate_limits.seven_day.used_percentage` | 7일 창 사용률 (0~100) |
| `rate_limits.five_hour.resets_at` | 5시간 창 리셋 시점 (Unix 타임스탬프) |
| `rate_limits.seven_day.resets_at` | 7일 창 리셋 시점 (Unix 타임스탬프) |

### 기타

| 필드 | 설명 |
|------|------|
| `session_id` | 고유 세션 식별자 |
| `version` | Claude Code 버전 |
| `vim.mode` | Vim 모드 상태 (`NORMAL` / `INSERT`) |
| `agent.name` | 에이전트 이름 (`--agent` 플래그 사용 시) |
| `worktree.name` | 활성 worktree 이름 |

> `rate_limits`는 첫 API 응답 이후에만 존재하며, `vim`과 `agent`는 해당 기능 사용 시에만 나타납니다. 스크립트에서 **null/부재 처리**를 반드시 해주세요.

## 6. 예제 스크립트

### 6.1 컨텍스트 프로그레스 바

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# 프로그레스 바 생성
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

echo "[$MODEL] $BAR $PCT%"
```

### 6.2 Git 상태 (컬러)

ANSI 이스케이프 코드로 색상을 표시합니다. 초록색은 staged, 노란색은 modified 파일입니다:

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"

    echo -e "[$MODEL] 📁 ${DIR##*/} | 🌿 $BRANCH $GIT_STATUS"
else
    echo "[$MODEL] 📁 ${DIR##*/}"
fi
```

### 6.3 비용 및 시간 추적

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

COST_FMT=$(printf '$%.2f' "$COST")
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

echo "[$MODEL] 💰 $COST_FMT | ⏱️ ${MINS}m ${SECS}s"
```

### 6.4 멀티라인 종합 대시보드

`echo`를 여러 번 호출하면 여러 줄로 표시됩니다. 컨텍스트 사용률에 따라 색상이 바뀝니다 (70% 미만: 초록, 70~89%: 노랑, 90% 이상: 빨강):

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# 사용률에 따른 색상 선택
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

# 첫째 줄: 모델, 디렉토리, Git 브랜치
echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH"
# 둘째 줄: 컨텍스트 바, 비용, 시간
COST_FMT=$(printf '$%.2f' "$COST")
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ⏱️ ${MINS}m ${SECS}s"
```

### 6.5 클릭 가능한 GitHub 링크

OSC 8 이스케이프 시퀀스를 사용하여 터미널에서 Cmd+클릭(macOS) 또는 Ctrl+클릭으로 링크를 열 수 있습니다. iTerm2, Kitty, WezTerm에서 지원됩니다:

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')

# Git SSH URL을 HTTPS로 변환
REMOTE=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')

if [ -n "$REMOTE" ]; then
    REPO_NAME=$(basename "$REMOTE")
    printf '%b' "[$MODEL] 🔗 \e]8;;${REMOTE}\a${REPO_NAME}\e]8;;\a\n"
else
    echo "[$MODEL]"
fi
```

### 6.6 속도 제한 표시 (Claude.ai 구독자용)

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
# "// empty"는 필드가 없을 때 빈 출력 생성
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

LIMITS=""
[ -n "$FIVE_H" ] && LIMITS="5h: $(printf '%.0f' "$FIVE_H")%"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS }7d: $(printf '%.0f' "$WEEK")%"

[ -n "$LIMITS" ] && echo "[$MODEL] | $LIMITS" || echo "[$MODEL]"
```

### 6.7 캐싱으로 성능 최적화

`git status`같은 느린 명령은 5초마다 한 번만 실행하고 캐시합니다:

```bash
#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')

CACHE_FILE="/tmp/statusline-git-cache"
CACHE_MAX_AGE=5  # 초

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git branch --show-current 2>/dev/null)
        STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
    else
        echo "||" > "$CACHE_FILE"
    fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

if [ -n "$BRANCH" ]; then
    echo "[$MODEL] 📁 ${DIR##*/} | 🌿 $BRANCH +$STAGED ~$MODIFIED"
else
    echo "[$MODEL] 📁 ${DIR##*/}"
fi
```

## 7. Windows 설정

Windows에서는 Claude Code가 Git Bash를 통해 상태 표시줄 명령을 실행합니다. PowerShell을 호출할 수도 있습니다:

**settings.json:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -File C:/Users/username/.claude/statusline.ps1"
  }
}
```

**statusline.ps1:**
```powershell
$input_json = $input | Out-String | ConvertFrom-Json
$cwd = $input_json.cwd
$model = $input_json.model.display_name
$used = $input_json.context_window.used_percentage
$dirname = Split-Path $cwd -Leaf

if ($used) {
    Write-Host "$dirname [$model] ctx: $used%"
} else {
    Write-Host "$dirname [$model]"
}
```

## 8. 상태 표시줄 비활성화

```
> /statusline 삭제해줘
```

또는 `settings.json`에서 `statusLine` 필드를 직접 삭제합니다.

## 9. 테스트 및 디버깅

### 스크립트 테스트

mock 데이터로 스크립트를 독립 실행하여 테스트합니다:

```bash
echo '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":25}}' | ./statusline.sh
```

### 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| 상태 표시줄이 안 보임 | `chmod +x` 확인, stdout 출력 여부 확인, `claude --debug`로 디버그 |
| `--`나 빈 값 표시 | 첫 API 응답 전에는 null일 수 있음. `// 0` 같은 기본값 처리 추가 |
| 컨텍스트 % 불일치 | `used_percentage` 사용 권장. 누적 토큰은 컨텍스트 크기를 초과할 수 있음 |
| OSC 8 링크 안 됨 | iTerm2, Kitty, WezTerm에서만 지원. Terminal.app은 미지원 |
| 표시 깨짐 | 복잡한 이스케이프 시퀀스 대신 단순 텍스트로 변경해보기 |
| Workspace trust 필요 | Claude Code 재시작 후 trust 프롬프트 승인 |

### 참고: 커뮤니티 프로젝트

사전 구성된 테마와 추가 기능을 제공하는 프로젝트들:
- [ccstatusline](https://github.com/sirmalloc/ccstatusline)
- [starship-claude](https://github.com/martinemde/starship-claude)

## 10. 개발자 추천: 대시보드 스타일 따라하기

실제로 사용 중인 2줄 대시보드 스타일입니다. 컨텍스트 바, 비용, 시간, 입출력 토큰, Git 정보를 한눈에 보여주고, 폴더명과 브랜치에 GitHub 클릭 링크까지 포함되어 있습니다.

**완성된 모습:**

```
◆ Opus │ 📂 Claude-Code-Guide │ ⎇ main ~1
━╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌  6% │ $0.42 │ ⏱ 2m33s │ ↑15.2k ↓4.5k
```

**각 요소 설명:**

| 요소 | 의미 |
|------|------|
| `◆ Opus` | 현재 사용 중인 모델 |
| `📂 Claude-Code-Guide` | 프로젝트 폴더 (Ctrl+클릭 시 GitHub 레포로 이동*) |
| `⎇ main` | 현재 Git 브랜치 (Ctrl+클릭 시 GitHub 브랜치 페이지*) |
| `+2 ~3` | staged 파일 수(초록) / modified 파일 수(노랑) |
| `━╌╌╌...` | 컨텍스트 프로그레스 바 (초록→노랑→빨강으로 색상 변화) |
| `$0.42` | 현재 세션 비용 |
| `⏱ 2m33s` | 세션 경과 시간 |
| `↑15.2k` | 입력 토큰 (Claude에게 보낸 양) |
| `↓4.5k` | 출력 토큰 (Claude가 생성한 양) |

> *클릭 링크는 iTerm2, Kitty, WezTerm, Windows Terminal에서 지원됩니다. WSL 기본 콘솔이나 tmux 내부에서는 동작하지 않습니다.

### 설정 방법

#### 1단계: jq 설치

이 스크립트는 JSON 파서인 `jq`가 필요합니다.

```bash
# Ubuntu / WSL
sudo apt-get install -y jq

# macOS
brew install jq

# 설치 확인
jq --version
```

#### 2단계: 스크립트 생성

`~/.claude/statusline.sh` 파일을 만듭니다:

```bash
#!/bin/bash
# 대시보드 — 2줄 + 클릭 가능한 GitHub 링크
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# 색상
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'
DIM='\033[2m'; BOLD='\033[1m'; RESET='\033[0m'

# OSC 8 링크 헬퍼: osc8_link URL TEXT → 클릭 가능한 텍스트 생성
osc8_link() { printf '\033]8;;%s\a%s\033]8;;\a' "$1" "$2"; }

# 컨텍스트 바 (20칸, 사용률에 따라 색상 변경)
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

BAR_WIDTH=20
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /━}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /╌}"

COST_FMT=$(printf '%.2f' "$COST")
MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

# 토큰 수를 k 단위로 포맷 (15234 → 15.2k)
fmt_tokens() {
    local n=$1
    if [ "$n" -ge 1000 ]; then
        printf '%.1fk' "$(echo "$n / 1000" | bc -l)"
    else
        echo "$n"
    fi
}
IN_FMT=$(fmt_tokens "$IN_TOKENS")
OUT_FMT=$(fmt_tokens "$OUT_TOKENS")

# Git 정보 + GitHub 링크
GIT_INFO=""
REPO_LINK=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

    # GitHub remote URL 가져오기 (SSH → HTTPS 변환)
    REMOTE=$(git remote get-url origin 2>/dev/null \
        | sed 's|git@github.com:|https://github.com/|' \
        | sed 's|\.git$||')

    # 브랜치 표시 (클릭 시 GitHub 브랜치 페이지로 이동)
    if [ -n "$REMOTE" ] && [ -n "$BRANCH" ]; then
        BRANCH_URL="${REMOTE}/tree/${BRANCH}"
        BRANCH_DISPLAY=$(osc8_link "$BRANCH_URL" "⎇ ${BRANCH}")
        GIT_INFO="${DIM}│${RESET} ${GREEN}${BRANCH_DISPLAY}${RESET}"
    elif [ -n "$BRANCH" ]; then
        GIT_INFO="${DIM}│${RESET} ${GREEN}⎇ ${BRANCH}${RESET}"
    fi
    [ "$STAGED" -gt 0 ] && GIT_INFO="${GIT_INFO} ${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_INFO="${GIT_INFO} ${YELLOW}~${MODIFIED}${RESET}"

    # 폴더명을 GitHub 레포 링크로 (클릭 시 GitHub 메인 페이지로 이동)
    if [ -n "$REMOTE" ]; then
        REPO_LINK=$(osc8_link "$REMOTE" "📂 ${DIR##*/}")
    fi
fi

# 폴더명: 링크가 있으면 클릭 가능, 없으면 일반 텍스트
FOLDER_DISPLAY="${REPO_LINK:-📂 ${DIR##*/}}"

# 1줄: 모델 · 디렉토리(클릭→GitHub) · Git 브랜치(클릭→브랜치 페이지)
printf '%b\n' "${BOLD}${CYAN}◆ ${MODEL}${RESET} ${DIM}│${RESET} ${FOLDER_DISPLAY} ${GIT_INFO}"
# 2줄: 컨텍스트 바 · 비용 · 시간 · 입출력 토큰
printf '%b\n' "${BAR_COLOR}${BAR}${RESET} ${PCT}% ${DIM}│${RESET} ${YELLOW}\$${COST_FMT}${RESET} ${DIM}│${RESET} ⏱ ${MINS}m${SECS}s ${DIM}│${RESET} ${CYAN}↑${IN_FMT}${RESET} ${YELLOW}↓${OUT_FMT}${RESET}"
```

#### 3단계: 실행 권한 부여

```bash
chmod +x ~/.claude/statusline.sh
```

#### 4단계: settings.json에 등록

`~/.claude/settings.json`에 추가합니다:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2
  }
}
```

#### 5단계: 확인

Claude Code를 재시작하면 하단에 대시보드가 표시됩니다. mock 데이터로 미리 테스트할 수도 있습니다:

```bash
echo '{"model":{"display_name":"Opus"},"workspace":{"current_dir":"/home/user/my-project"},"cost":{"total_cost_usd":0.42,"total_duration_ms":153000},"context_window":{"used_percentage":6,"context_window_size":200000,"total_input_tokens":15234,"total_output_tokens":4521}}' | ~/.claude/statusline.sh
```

---
> 💡 **Tip:** 출력은 짧게 유지하세요. 상태 바 너비가 제한되어 있어 긴 출력은 잘리거나 줄 바꿈이 될 수 있습니다. 또한 느린 명령(git status 등)은 캐싱 패턴을 적용하면 표시줄 업데이트가 훨씬 매끄러워집니다.
