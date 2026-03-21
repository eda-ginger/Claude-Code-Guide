---
name: claudeclaw
description: "Claude Code Channels 텔레그램 연동 설치 가이드. 텔레그램 봇 생성부터 채널 페어링, 보안 설정까지 초보자도 따라할 수 있는 단계별 안내."
---

# ClaudeClaw - Claude Code Channels 텔레그램 연동 가이드

Claude Code의 **Channels** 기능을 사용하여 텔레그램에서 직접 Claude에게 작업을 지시할 수 있도록 연동하는 설치 가이드 스킬입니다.

> **Channels란?** MCP(Model Context Protocol)에서 외부 서비스가 Claude 세션으로 직접 프롬프트를 Push할 수 있는 기능입니다. 기존에는 Claude가 MCP를 호출해야 했지만, Channels를 통해 텔레그램 같은 외부에서 Claude에게 직접 명령을 보낼 수 있습니다.

---

## 사전 준비물

- Claude Code CLI 설치 완료
- 텔레그램 앱 (모바일 또는 데스크톱)
- 텔레그램 계정

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
- 아직 **프리뷰(Preview)** 기능이므로 일부 불안정할 수 있습니다.

### 1-3. 플러그인 활성화

설치 완료 후 아래 명령어로 플러그인을 활성화합니다:

```
reload plugins
```

> **잘 안 될 때:** Claude Code를 완전히 종료(`exit`)했다가 다시 실행하세요.

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
<your-bot-token>
```

이 토큰을 **복사**합니다.

> **주의:** API 토큰은 비밀번호와 같습니다. 절대 다른 사람에게 공유하지 마세요.

### 2-3. Claude Code에 토큰 등록

Claude Code 프롬프트로 돌아와서 아래 명령어를 입력합니다:

```
/telegram:config <your-bot-token>
```

엔터를 눌러 설정을 적용합니다.

---

## 3단계: 채널 연결 (페어링)

### 3-1. Claude Code 재시작

Claude Code를 한 번 종료(`exit`)했다가 다시 실행합니다.

### 3-2. 채널 수신 대기 시작

아래 명령어를 입력합니다:

```
plugin:channels telegram@claude-plugins/official
```

화면에 다음 메시지가 나오면 정상입니다:

```
listening for channels message...
```

> **이 메시지가 안 나오면:** 1단계의 플러그인 설치가 제대로 되었는지 확인하세요. `reload plugins`를 다시 시도해 보세요.

### 3-3. 텔레그램에서 봇 시작

1. 텔레그램 앱으로 돌아갑니다.
2. 방금 만든 봇을 검색합니다 (2단계에서 설정한 사용자명으로).
3. **Start** 버튼을 누릅니다.

### 3-4. 페어링 코드 입력

1. 봇이 **텔레그램 액세스 페어(Telegram access pair)** 코드를 보내줍니다.
2. 이 코드를 **그대로 복사**합니다.
3. Claude Code 프롬프트에 **붙여넣기** 후 엔터를 누릅니다.
4. 승인(Yes) 프롬프트가 나오면 **Yes**를 선택합니다.

> **페어링 코드가 안 오면:** 봇을 `/start` 명령어로 다시 시작해 보세요.

---

## 4단계: 보안 설정 (Allowlist)

연결이 되었으면 보안을 강화합니다. 허가되지 않은 접근을 방지하기 위해 **반드시** 이 단계를 수행하세요.

Claude Code 프롬프트에 아래 명령어를 입력합니다:

```
/telegram:access-policy allowlist
```

승인(Yes)을 누르면:
- 허용 목록(Allowlist)에 등록된 봇만 소통 가능
- DM 폴리시가 잠금(Lockdown) 처리

> **왜 필요한가요?** Allowlist 없이는 누구나 봇을 통해 Claude에 접근할 수 있어 보안 위험이 있습니다.

---

## 5단계: 테스트

### 5-1. 간단한 메시지 테스트

텔레그램 봇 채팅창에 입력합니다:

```
Hi Claude
```

Claude Code 터미널에 메시지가 표시되면 **연동 성공**입니다!

### 5-2. 작업 명령 테스트

텔레그램에서 실제 작업 명령을 보내봅니다:

```
현재 디렉토리에 index.html 파일 만들어줘
```

Claude Code가 요청을 수신하고 작업을 시작하는 것을 확인합니다.

---

## 문제 해결 (트러블슈팅)

| 증상 | 해결 방법 |
|------|-----------|
| 플러그인 설치 실패 | 인터넷 연결 확인 후 Claude Code 재시작하고 다시 시도 |
| `listening for channels message...`가 안 나옴 | `reload plugins` 실행 후 재시도. 안 되면 Claude Code 완전 종료 후 재시작 |
| 텔레그램 봇에서 페어링 코드가 안 옴 | 봇에 `/start` 다시 입력. BotFather에서 토큰이 맞는지 확인 |
| 페어링 후에도 메시지가 안 옴 | Claude Code 재시작 후 `plugin:channels telegram@claude-plugins/official` 다시 실행 |
| API 토큰 오류 | BotFather에서 `/token` 명령으로 토큰 재확인. `/telegram:config`로 다시 설정 |

---

## 참고: 전체 명령어 요약 (Quick Reference)

```bash
# 1. Claude Code 실행 (권한 스킵 모드)
claude --dangerously-skip-permissions

# 2. 텔레그램 플러그인 설치
install telegram@claude-plugins/official

# 3. 플러그인 리로드
reload plugins

# 4. API 토큰 설정 (BotFather에서 발급받은 토큰)
/telegram:config YOUR_BOT_TOKEN

# 5. Claude Code 재시작 후 채널 활성화
plugin:channels telegram@claude-plugins/official

# 6. 텔레그램 봇에서 받은 페어링 코드 붙여넣기
# (코드를 그대로 붙여넣고 엔터)

# 7. 보안 설정 (Allowlist)
/telegram:access-policy allowlist
```

---

## 추가 활용

- **커스텀 채널 확장**: Anthropic의 'Build your own channel' 문서를 참고하면 텔레그램 외에도 자체 서비스(SaaS 등)에서 Claude 세션에 프롬프트를 직접 보내는 구조를 만들 수 있습니다.
- **활용 예시**: 슬랙 봇, 디스코드 봇, 자체 웹 대시보드 등에서 Claude Code로 작업 지시 가능
