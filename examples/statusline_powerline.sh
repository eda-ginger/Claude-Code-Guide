#!/bin/bash
# Style 2: 파워라인 — 구분자와 컬러로 구간을 나눈 스타일
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# 색상
BG_BLUE='\033[44m'; BG_PURPLE='\033[45m'; BG_RESET='\033[49m'
FG_WHITE='\033[97m'; FG_CYAN='\033[36m'; FG_YELLOW='\033[33m'; FG_GREEN='\033[32m'
BOLD='\033[1m'; RESET='\033[0m'

COST_FMT=$(printf '%.2f' "$COST")
MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

# Git 브랜치
BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
fi

# 출력 예시:  Opus  │  main  │  📁 project  │  6%  │  $0.42  │  2m 30s
LINE="${BOLD}${FG_CYAN} ${MODEL} ${RESET}"
[ -n "$BRANCH" ] && LINE="${LINE} │ ${FG_GREEN} ${BRANCH}${RESET}"
LINE="${LINE} │ ${FG_WHITE}📁 ${DIR##*/}${RESET}"
LINE="${LINE} │ ${FG_YELLOW}${PCT}%${RESET}"
LINE="${LINE} │ ${FG_YELLOW}\$${COST_FMT}${RESET}"
LINE="${LINE} │ ⏱ ${MINS}m ${SECS}s"

echo -e "$LINE"
