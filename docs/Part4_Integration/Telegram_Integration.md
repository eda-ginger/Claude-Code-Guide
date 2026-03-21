# 텔레그램 연동 가이드 (Claude Code Channels)

이 문서에서는 Claude Code의 **Channels** 기능을 활용하여 텔레그램에서 직접 Claude에게 작업을 지시하는 방법을 안내합니다.

> **Channels란?** MCP(Model Context Protocol)에서 외부 서비스가 Claude 세션으로 직접 프롬프트를 Push할 수 있는 기능입니다. 기존에는 Claude가 MCP를 호출해야 했지만, Channels를 통해 텔레그램 같은 외부에서 Claude에게 직접 명령을 보낼 수 있습니다.

---

## 사전 준비물

- Claude Code CLI 설치 완료
- 텔레그램 앱 (모바일 또는 데스크톱)
- 텔레그램 계정

---

## 0단계: `/claudeclaw` 스킬 사용

이 저장소를 clone하면 `.claude/skills/claudeclaw/SKILL.md` 스킬이 자동으로 포함됩니다. Claude Code에서 `/claudeclaw`를 입력하면 아래 가이드를 Claude가 단계별로 안내해 줍니다.

> 스킬에 대한 자세한 내용은 [고급 기능 가이드](../Part3_Advanced/Advanced_Features.md)를 참고하세요.

---

## 1단계: 텔레그램 플러그인 설치

### 1-1. Claude Code 실행

```bash
claude --dangerously-skip-permissions
```

> 권한 스킵 모드로 실행하면 설치 과정에서 매번 승인을 누르지 않아도 됩니다. 설치가 끝나면 일반 모드로 다시 실행해도 괜찮습니다.

### 1-2. 텔레그램 플러그인 설치

Claude Code 프롬프트에 아래 명령어를 입력합니다:

```
install telegram@claude-plugins/official
```

- 설치 범위(scope)를 물으면 **project** 또는 **user** 중 원하는 범위를 선택합니다.

### 1-3. 플러그인 활성화

설치 완료 후 아래 명령어로 플러그인을 활성화합니다:

```
reload plugins
```

> 잘 안 될 때는 Claude Code를 완전히 종료(`exit`)했다가 다시 실행하세요.

---

## 2단계: 텔레그램 봇 생성 및 토큰 발급

### 2-1. BotFather에서 봇 만들기

1. 텔레그램 앱을 열고 검색창에 **BotFather**를 검색합니다.
2. BotFather 채팅에서 **Start** 버튼을 누릅니다.
3. `/newbot` 명령어를 입력합니다.
4. 봇의 **표시 이름**(예: `My Claude Bot`)을 입력합니다.
5. 봇의 **사용자명**(예: `my_claude_helper_bot`)을 입력합니다.
   - 반드시 `bot`으로 끝나야 합니다.

### 2-2. API 토큰 복사

봇 생성이 완료되면 BotFather가 다음과 같은 메시지를 보냅니다:

```
Use this token to access the HTTP API:
123456789:AAH_your_token_here
```

이 토큰을 **복사**합니다.

> **주의:** API 토큰은 비밀번호와 같습니다. 절대 다른 사람에게 공유하지 마세요.

### 2-3. Claude Code에 토큰 등록

Claude Code 프롬프트로 돌아와서 아래 명령어를 입력합니다:

```
/telegram:configure <복사한_토큰>
```

---

## 3단계: 채널 연결 (페어링)

### 3-1. Claude Code 재시작

토큰 설정 후 Claude Code를 종료(`exit`)했다가 다시 실행합니다.

### 3-2. 채널 수신 대기 시작

아래 명령어를 입력합니다:

```
plugin:channels telegram@claude-plugins/official
```

화면에 다음 메시지가 나오면 정상입니다:

```
listening for channels message...
```

### 3-3. 텔레그램에서 봇에 DM 보내기

1. 텔레그램 앱에서 방금 만든 봇을 검색합니다.
2. **Start** 버튼을 누릅니다.
3. 봇이 페어링 안내 메시지를 보내줍니다:

```
This bot bridges Telegram to a Claude Code session.

To pair:
1. DM me anything — you'll get a 6-char code
2. In Claude Code: /telegram:access pair <code>
```

4. 아무 메시지나 보내면 **6자리 페어링 코드**를 받습니다.

### 3-4. 페어링 코드로 승인

Claude Code 프롬프트에 아래 명령어를 입력합니다:

```
/telegram:access pair <6자리_코드>
```

승인이 완료되면 텔레그램 봇이 "you're in" 메시지를 보내줍니다.

---

## 4단계: 보안 설정 (Allowlist 잠금)

페어링이 완료되면 **반드시** 보안을 강화하세요. 기본 정책(`pairing`)은 누구나 봇에 DM을 보내 페어링 코드를 요청할 수 있어 보안에 취약합니다.

```
/telegram:access policy allowlist
```

이 명령어를 실행하면:
- 허용 목록(Allowlist)에 등록된 사용자만 봇과 소통 가능
- 새로운 페어링 요청이 차단됨

> **나중에 다른 사용자를 추가하려면?** 일시적으로 `pairing`으로 전환 → 새 사용자 페어링 → 다시 `allowlist`로 잠금:
> ```
> /telegram:access policy pairing     # 임시 개방
> /telegram:access pair <새_코드>      # 새 사용자 승인
> /telegram:access policy allowlist   # 다시 잠금
> ```

---

## 5단계: 테스트

### 간단한 메시지 테스트

텔레그램 봇 채팅창에 입력합니다:

```
안녕 Claude!
```

Claude Code 터미널에 메시지가 표시되고 텔레그램으로 답변이 오면 **연동 성공**입니다!

### 작업 명령 테스트

텔레그램에서 실제 작업 명령을 보내봅니다:

```
현재 프로젝트의 README.md 내용을 요약해줘
```

---

## 문제 해결 (트러블슈팅)

| 증상 | 해결 방법 |
|------|-----------|
| 플러그인 설치 실패 | 인터넷 연결 확인 후 Claude Code 재시작하고 다시 시도 |
| `listening for channels message...`가 안 나옴 | `reload plugins` 실행 후 재시도. 안 되면 Claude Code 완전 종료 후 재시작 |
| 봇에서 페어링 코드가 안 옴 | 봇에 `/start` 다시 입력. BotFather에서 토큰이 맞는지 확인 |
| 페어링 후에도 메시지가 안 옴 | Claude Code 재시작 후 `plugin:channels` 다시 실행 |
| API 토큰 오류 | BotFather에서 `/token` 명령으로 토큰 재확인 후 `/telegram:configure`로 다시 설정 |

---

## 전체 명령어 요약 (Quick Reference)

```bash
# 1. Claude Code 실행 (권한 스킵 모드)
claude --dangerously-skip-permissions

# 2. 텔레그램 플러그인 설치
install telegram@claude-plugins/official

# 3. 플러그인 리로드
reload plugins

# 4. API 토큰 설정
/telegram:configure YOUR_BOT_TOKEN

# 5. Claude Code 재시작 후 채널 활성화
plugin:channels telegram@claude-plugins/official

# 6. 텔레그램 봇에서 받은 페어링 코드로 승인
/telegram:access pair <6자리_코드>

# 7. 보안 잠금 (Allowlist)
/telegram:access policy allowlist
```

---

## 주요 접근 관리 명령어

| 명령어 | 설명 |
|--------|------|
| `/telegram:access` | 현재 접근 상태 확인 |
| `/telegram:access pair <코드>` | 페어링 코드 승인 |
| `/telegram:access policy allowlist` | Allowlist 모드로 잠금 |
| `/telegram:access policy pairing` | 페어링 모드로 전환 (임시) |
| `/telegram:access allow <사용자ID>` | 사용자 직접 추가 |
| `/telegram:access remove <사용자ID>` | 사용자 제거 |

---

## 활용 팁

- **외출 중 작업 지시**: 텔레그램으로 "테스트 실행해줘", "빌드 상태 확인해줘" 등 원격 작업 가능
- **파일 전송**: 텔레그램에서 이미지나 파일을 보내면 Claude가 확인하고 처리 가능
- **tmux와 함께 사용**: [tmux 가이드](../Part3_Advanced/Tmux_and_Agent_Teams.md)의 tmux 설정과 함께 사용하면 Claude Code 세션을 백그라운드로 유지하면서 텔레그램으로 지시 가능
