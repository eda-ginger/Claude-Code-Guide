#!/bin/bash
# Style 3: 대시보드 — 2줄 + 클릭 가능한 GitHub 링크
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
