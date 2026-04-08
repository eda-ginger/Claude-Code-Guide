# tmux 실행 환경

tmux를 사용하면 Claude Code 세션을 백그라운드에서 유지하고, 언제든 돌아올 수 있습니다.

---

## 1. 왜 tmux인가

- **세션 유지**: 터미널을 닫아도 작업이 계속 실행
- **복귀 가능**: 나중에 돌아와서 이어서 작업
- **원격 서버**: 인터넷 연결이 끊겨도 세션 유지

Claude Code처럼 장시간 돌아가는 AI 작업에 딱 맞습니다.

---

## 2. 설치 및 기본 설정

### tmux 설치

```bash
# macOS
brew install tmux

# Ubuntu / WSL
sudo apt install tmux
```

### 마우스 스크롤 활성화

```bash
echo 'set -g mouse on' >> ~/.tmux.conf
tmux source-file ~/.tmux.conf    # 이미 실행 중이면 즉시 반영
```

---

## 3. `cl` alias — 한 글자로 시작

긴 명령어 대신 `cl`만 치면 Claude Code가 tmux 세션과 함께 실행됩니다.

### 설정 (macOS: ~/.zshrc, Linux: ~/.bashrc)

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
cl() {
  local sess="cl-$(basename "$PWD" | tr -cd 'a-zA-Z0-9_-')"
  if [ -z "$TMUX" ]; then
    tmux has-session -t "$sess" 2>/dev/null || tmux new-session -d -s "$sess" -c "$PWD" "claude"
    tmux attach -t "$sess"
  else
    claude
  fi
}
```

```bash
source ~/.zshrc   # 설정 적용
```

### 이 alias가 하는 일

- 일반 터미널에서 `cl` → tmux 세션 생성 + Claude Code 실행
- 이미 tmux 안에서 `cl` → 중첩 없이 바로 Claude Code 실행
- **프로젝트 폴더별 세션 자동 분리**: `~/my-project`에서 `cl` → `cl-my-project` 세션

### 기억할 명령어 3개

| 명령어 | 기능 |
|--------|------|
| `cl` | Claude Code 시작 (또는 돌아오기) |
| `Ctrl+b` → `d` | 세션에서 나가기 (백그라운드 유지) |
| `exit` | 완전 종료 |

### 실제 사용 예시

```
1. cl로 Claude Code 시작
2. 복잡한 리팩토링 작업을 맡겨놓고
3. Ctrl+b, d로 세션에서 나가기
4. 회의 다녀오고
5. cl로 돌아와서 결과 확인
```

---

## 4. `cl-claw` — 텔레그램 원격 제어

텔레그램 봇과 연동하여 외출 중에도 Claude Code에 작업을 지시할 수 있습니다.

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
clclaw() {
  local sess="claw-$(basename "$PWD" | tr -cd 'a-zA-Z0-9_-')"
  if [ -z "$TMUX" ]; then
    tmux has-session -t "$sess" 2>/dev/null || tmux new-session -d -s "$sess" -c "$PWD" "claude --channels plugin:telegram@claude-plugins-official"
    tmux attach -t "$sess"
  else
    claude --channels plugin:telegram@claude-plugins-official
  fi
}
alias cl-claw='clclaw'
```

### cl vs cl-claw

| | `cl` | `cl-claw` |
|--|------|-----------|
| 세션 이름 | `cl-{폴더명}` | `claw-{폴더명}` |
| 텔레그램 연동 | ❌ | ✅ |
| 사용 시나리오 | 직접 작업 | 원격 지시, 백그라운드 |

### 프로젝트별 봇 운영

각 프로젝트 폴더에 `.claude/channels/telegram/.env`로 전용 봇 토큰을 설정하면, `cl-claw` 실행 시 해당 프로젝트 전용 봇이 활성화됩니다.

```
프로젝트 A/.claude/channels/telegram/.env  →  봇 A
프로젝트 B/.claude/channels/telegram/.env  →  봇 B
```

> 텔레그램 봇 생성부터 설정까지의 상세 가이드는 [Part4-Appendix/telegram](../Part4-Appendix/02-telegram.md)을 참고하세요.

---

> 💡 **Tip:** `cl`은 직접 작업할 때, `cl-claw`는 텔레그램으로 원격 지시할 때 쓰면 됩니다. 같은 프로젝트에서 두 세션을 동시에 띄울 수도 있습니다 — 세션 이름이 다르기 때문에 충돌하지 않습니다.
