# Claude Dashboard 설정

> 이 문서를 Claude에게 보여주면 claude-dashboard 플러그인 설치부터 커스텀 테마 적용까지 자동으로 수행합니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 실행 환경 | `claude --version` |
| Node.js | 플러그인 런타임 | `node -v` |

## 1. 플러그인 설치

Claude Code 터미널에서 순서대로 실행:

```bash
/plugin marketplace add uppinote20/claude-dashboard
/plugin install claude-dashboard
/reload-plugins
```

## 2. 설정 파일 생성

`~/.claude/claude-dashboard.local.json`을 생성:

```json
{
  "language": "en",
  "plan": "max",
  "displayMode": "custom",
  "lines": [
    ["todayCost", "context", "rateLimit5h"],
    ["rateLimit7d", "rateLimit7dSonnet"],
    ["model", "version", "configCounts"],
    ["projectInfo"],
    ["outputStyle"]
  ],
  "spacerAfterLine": [1],
  "theme": "default",
  "separator": "pipe",
  "cache": {
    "ttlSeconds": 300
  }
}
```

## 3. statusLine 경로 설정

`/claude-dashboard:update`를 실행하면 자동 설정된다. 수동 설정이 필요하면 `~/.claude/settings.json`에 추가:

```json
{
  "statusLine": {
    "type": "command",
    "command": "node ~/.claude/plugins/cache/claude-dashboard/claude-dashboard/VERSION/dist/index.js"
  }
}
```

VERSION 확인:

```bash
ls ~/.claude/plugins/cache/claude-dashboard/claude-dashboard/
```

## 4. 커스텀 코드 수정

아래 수정은 모두 `dist/index.js`에 적용한다. 경로:

```
~/.claude/plugins/cache/claude-dashboard/claude-dashboard/VERSION/dist/index.js
```

먼저 VERSION을 확인하고 해당 파일을 수정한다.

### 4-1. 프로그레스바 스타일

`DEFAULT_PROGRESS_BAR_CONFIG`에서 변경:

```js
// 변경 전
filledChar: "\u2588",  // █
emptyChar: "\u2591"    // ░

// 변경 후
filledChar: "\u25AC",  // ▬
emptyChar: "\u25AC"    // ▬
```

`renderProgressBar` 함수를 아래로 교체:

```js
function renderProgressBar(percent, configOrColor = DEFAULT_PROGRESS_BAR_CONFIG) {
  const config = typeof configOrColor === "string" ? DEFAULT_PROGRESS_BAR_CONFIG : configOrColor;
  const customColor = typeof configOrColor === "string" ? configOrColor : null;
  const { width, filledChar, emptyChar } = config;
  const clampedPercent = Math.max(0, Math.min(100, percent));
  const filled = Math.round(clampedPercent / 100 * width);
  const empty = width - filled;
  const theme = getTheme();
  const color = customColor || getColorForPercent(clampedPercent);
  const filledBar = `${color}${filledChar.repeat(filled)}${RESET}`;
  const emptyBar = `${theme.barEmpty}${emptyChar.repeat(empty)}${RESET}`;
  return filledBar + emptyBar;
}
```

### 4-2. default 테마 색상

`THEMES.default`에서 변경:

```js
model: "\x1B[38;5;216m",     // 파스텔 주황
barEmpty: "\x1B[38;5;238m",  // 어두운 회색
```

### 4-3. todayCost 위젯 라벨

`todayCostWidget`의 `render`에서:

```js
// 변경 전
return colorize(`💰 ${t.widgets.todayCost}: ${formatCost(data.dailyTotal)}`, getTheme().secondary);

// 변경 후
return colorize(`🎧 Daily Usage`, getTheme().secondary);
```

### 4-4. context 위젯 (Ctx 라벨 + 빨간 프로그레스바)

`contextWidget`의 `render`를 아래로 교체:

```js
render(data, _ctx) {
    const percentColor = getColorForPercent(data.percentage);
    const pctStr = `${data.percentage}%`;
    const padPct = pctStr.padStart(4);
    const tokenStr = `(${formatTokens(data.inputTokens)}/${formatTokens(data.contextSize)})`;
    const padToken = colorize(tokenStr.padEnd(12), getTheme().barEmpty);
    return `${colorize("Ctx", getTheme().danger)} ${renderProgressBar(data.percentage, getTheme().danger)} ${colorize(padPct, percentColor)} ${padToken}`;
}
```

### 4-5. rateLimit 위젯

`renderRateLimit` 함수를 아래로 교체:

```js
function renderRateLimit(data, ctx, labelKey, barColor) {
  if (data.isError) return colorize("⚠️", getTheme().warning);
  const { translations: t } = ctx;
  const color = getColorForPercent(data.utilization);
  const bar = barColor ? renderProgressBar(data.utilization, barColor) : renderProgressBar(data.utilization);
  const pctStr = `${data.utilization}%`;
  const padPct = pctStr.padStart(4);
  const timeStr = data.resetsAt ? `(${formatTimeRemaining(data.resetsAt, t)})` : "";
  const padTime = colorize(timeStr.padEnd(12), getTheme().barEmpty);
  const labelColor = barColor || getColorForPercent(data.utilization);
  return `${colorize(t.labels[labelKey], labelColor)} ${bar} ${colorize(padPct, color)} ${padTime}`;
}
```

각 위젯 render에서 색상 지정:

```js
// rateLimit5h → 하늘색
render(data, ctx) { return renderRateLimit(data, ctx, "5h", getTheme().info); }

// rateLimit7d → 초록색 + 라벨
render(data, ctx) {
  return colorize("📅 7days Usage", getTheme().secondary) + getSeparator() + renderRateLimit(data, ctx, "7d_all", getTheme().safe);
}

// rateLimit7dSonnet → 초록색
render(data, ctx) { return renderRateLimit(data, ctx, "7d_sonnet", getTheme().safe); }
```

### 4-6. 영어 라벨

`en_default` 객체의 `labels`에서:

```js
"7d_all": "All",      // 원래: "7d"
"7d_sonnet": "Sn",    // 원래: "7d-S"
```

### 4-7. model 위젯 (effort 제거)

`modelWidget`의 `render`를 아래로 교체:

```js
render(data) {
    const shortName = shortenModelName(data.displayName);
    const icon = isZaiProvider() ? "🟠" : "🔥";
    const version = data.id.includes("opus") ? "4.6" : data.id.includes("sonnet") ? "4.6" : data.id.includes("haiku") ? "4.5" : "";
    const fastIndicator = shortName === "Opus" && data.fastMode ? " ↯" : "";
    return `${getTheme().model}${icon} ${shortName} ${version}${fastIndicator}${RESET}`;
}
```

### 4-8. version 위젯

`versionWidget`의 `render`를 아래로 교체:

```js
render(data, _ctx) {
    return colorize(`Claude v${data.version}`, getTheme().model);
}
```

### 4-9. configCounts 위젯

`configCountsWidget`의 `render`에서 숫자를 앞으로, MCP/Hooks 항상 표시:

```js
parts.push(`${data.claudeMd} ${t.widgets.claudeMd}`);
parts.push(`${data.mcps} ${t.widgets.mcps}`);
parts.push(`${data.hooks} ${t.widgets.hooks}`);
return parts.map(p => colorize(p, getTheme().secondary)).join(getSeparator());
```

`countMcps` 함수에서 `claude mcp list`로 실제 연결 수 카운트:

```js
try {
  const { execSync } = await import("child_process");
  const output = execSync("claude mcp list", { encoding: "utf-8", timeout: 10000, shell: "bash" });
  const connected = (output.match(/Connected/g) || []).length;
  return connected > fileCount ? connected : fileCount;
} catch {
  return fileCount;
}
```

`getData`에서 null 체크를 제거하고 항상 반환:

```js
const fsData = { claudeMd, agentsMd, rules, mcps, hooks };
return { ...fsData, addedDirs };
```

### 4-10. 시간 포맷

`formatTimeRemaining` 함수에서 일/시간 사이에 스페이스 추가:

```js
// 변경 전
`${days}${t.time.days}${hours}${t.time.hours}`

// 변경 후
`${days}${t.time.days} ${hours}${t.time.hours}`
```

### 4-11. 구분선 색상

`getSeparator` 함수에서:

```js
// 변경 전
` ${getTheme().dim}${char}${RESET} `

// 변경 후
` ${getTheme().barEmpty}${char}${RESET} `
```

### 4-12. 빈 줄 (spacerAfterLine) 지원

`formatOutput` 함수를 아래로 교체:

```js
async function formatOutput(ctx) {
  const lines = await renderAllLines(ctx);
  const spacerAfter = ctx.config.spacerAfterLine ?? [];
  const result = [];
  for (let i = 0; i < lines.length; i++) {
    result.push(lines[i]);
    if (spacerAfter.includes(i)) {
      result.push("\u200B");
    }
  }
  return result.join("\n");
}
```

## 5. 최종 결과

```
🎧 Daily Usage │ Ctx ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬  13% (131K/1.0M) │ 5h ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬  14% (2h 5m)
📅 7days Usage │ All ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬  24% (2d 2h)     │ Sn ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬   0% (5d 3h)

🔥 Opus 4.6 │ Claude v2.1.108 │ 1 CLAUDE.md │ 4 MCP │ 0 Hooks
📁 PARK
▶▶ bypass permissions on (shift+tab to cycle)
```

## 6. WSL 환경 세팅

WSL은 Windows와 홈 디렉토리가 다르므로 별도 세팅이 필요하다.

Windows에서 이미 세팅된 경우 복사:

```bash
# 설정 파일 복사
cp /mnt/c/Users/PARK/.claude/claude-dashboard.local.json ~/.claude/claude-dashboard.local.json

# 커스텀 수정된 index.js 복사
WINDOWS_VER=$(ls /mnt/c/Users/PARK/.claude/plugins/cache/claude-dashboard/claude-dashboard/ | head -1)
WSL_VER=$(ls ~/.claude/plugins/cache/claude-dashboard/claude-dashboard/ | head -1)
cp /mnt/c/Users/PARK/.claude/plugins/cache/claude-dashboard/claude-dashboard/$WINDOWS_VER/dist/index.js \
   ~/.claude/plugins/cache/claude-dashboard/claude-dashboard/$WSL_VER/dist/index.js
```

## 트러블슈팅

| 문제 | 해결 |
|------|------|
| 플러그인 업데이트 시 커스텀 초기화 | 업데이트 전 `dist/index.js` 백업 필수, 업데이트 후 4번 재적용 또는 백업 복원 |
| statusLine이 표시 안 됨 | `~/.claude/settings.json`의 statusLine 경로에서 VERSION 확인 |
| WSL에서 표시 안 됨 | Windows와 WSL은 별도 환경, 양쪽 모두 세팅 필요 |

---

> 💡 **Tip:** `/plugin update claude-dashboard` 실행 전에 반드시 `dist/index.js`를 백업하세요. 업데이트하면 커스텀 수정이 모두 초기화됩니다.
