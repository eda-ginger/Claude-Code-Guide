#!/bin/bash
# Style 5: 해커 — 터미널 감성의 모노크롬 스타일
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name' | tr '[:lower:]' '[:upper:]')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
CTX_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

# 녹색 모노크롬
GREEN='\033[32m'; DIM_GREEN='\033[2;32m'; BRIGHT_GREEN='\033[1;32m'; RESET='\033[0m'

COST_FMT=$(printf '%.3f' "$COST")
MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))
CTX_K=$((CTX_SIZE / 1000))

# 프로그레스 바 (해커 스타일)
BAR_WIDTH=15
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /#}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /.}"

# Git
GIT=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    GIT=" git:${BRANCH}"
fi

# 출력 예시: [OPUS] ctx:[###............] 6%/200k | in:15234 out:4521 | $0.042 | 02:30
printf "${GREEN}[${BRIGHT_GREEN}${MODEL}${GREEN}]${RESET}"
printf "${DIM_GREEN}${GIT}${RESET}"
printf "${GREEN} ctx:[${BRIGHT_GREEN}${BAR}${GREEN}] ${PCT}%%/${CTX_K}k${RESET}"
printf "${DIM_GREEN} | in:${INPUT_TOKENS} out:${OUTPUT_TOKENS}${RESET}"
printf "${GREEN} | \$${COST_FMT}${RESET}"
printf "${DIM_GREEN} | $(printf '%02d:%02d' $MINS $SECS)${RESET}"
echo
