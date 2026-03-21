#!/bin/bash
# Style 1: 미니멀 — 핵심 정보만 깔끔하게 한 줄
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

COST_FMT=$(printf '%.2f' "$COST")

# 출력 예시: Opus · 6% · $0.42
echo "$MODEL · ${PCT}% · \$${COST_FMT}"
