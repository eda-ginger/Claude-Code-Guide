#!/bin/bash
# Style 4: 이모지 — 아이콘 중심으로 직관적 표시
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
LINES_ADD=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_DEL=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# 컨텍스트 레벨에 따른 이모지
if [ "$PCT" -ge 90 ]; then CTX_ICON="🔴"
elif [ "$PCT" -ge 70 ]; then CTX_ICON="🟡"
elif [ "$PCT" -ge 40 ]; then CTX_ICON="🟢"
else CTX_ICON="🔵"; fi

COST_FMT=$(printf '%.2f' "$COST")
MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

# Git
BRANCH_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    BRANCH_INFO="🌿 ${BRANCH}  "
fi

# 출력 예시: 🤖 Opus  🌿 main  🔵 6%  💰 $0.42  ⏱ 2m30s  📝 +15 -3
echo "🤖 ${MODEL}  ${BRANCH_INFO}${CTX_ICON} ${PCT}%  💰 \$${COST_FMT}  ⏱ ${MINS}m${SECS}s  📝 +${LINES_ADD} -${LINES_DEL}"
