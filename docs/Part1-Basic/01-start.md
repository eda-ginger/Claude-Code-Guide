# Claude Code 설치와 기본 사용법

Claude Code는 Anthropic이 만든 공식 CLI 기반 AI 코딩 어시스턴트입니다. 이 문서에서는 설치부터 첫 사용까지 한 번에 안내합니다.

---

## 1. 사전 요구사항

Claude Code는 Node.js 환경에서 동작합니다. **Node.js 18 이상**이 필요합니다.

```bash
node -v   # 버전 확인
npm -v    # npm 확인
```

### Node.js 설치 (미설치 시)

**[방법 A] 공식 홈페이지**
1. [nodejs.org](https://nodejs.org/)에서 **LTS 버전** 다운로드
2. 설치 프로그램 실행 (npm 자동 포함)

**[방법 B] NVM (버전 관리용)**
```bash
nvm install lts
nvm use lts
```
> Windows는 [nvm-windows](https://github.com/coreybutler/nvm-windows/releases)에서 설치 후 관리자 권한 터미널에서 실행.

> ⚠️ 설치 후 **터미널을 새로 열어야** `npm` 명령어가 동작합니다.

---

## 2. 설치

```bash
npm install -g @anthropic-ai/claude-code
```

설치 확인:
```bash
claude --version
```

---

## 3. 첫 실행과 인증

```bash
claude
```

1. 브라우저가 열리며 Anthropic 인증 페이지로 이동
2. 계정 로그인 → CLI 접근 권한 허용
3. 터미널에 `>` 프롬프트가 뜨면 준비 완료

> 프로젝트 폴더에서 `claude`를 실행하면 해당 코드를 바로 분석/수정할 수 있습니다.

---

## 4. 기본 사용법

### 코드 작성

자연어 지시만으로 코드를 생성합니다.

```
> Python으로 피보나치 수열을 계산하는 함수를 만들어줘
```

### 코드 읽기 및 질문

프로젝트 내 파일을 직접 읽고 분석합니다.

```
> src/main.py에서 calculate 함수가 어떤 역할을 하는지 설명해줘
> 이 프로젝트의 전체 구조를 알려줘
```

### 코드 수정

수정 전후 diff를 보여주고, 승인 후 적용됩니다.

```
> app.js의 에러 처리를 try-catch로 감싸줘
> 이 코드에서 중복된 부분을 리팩토링해줘
```

### 터미널 명령 실행

필요에 따라 명령어도 실행할 수 있습니다 (실행 전 승인 요청).

```
> npm install express를 실행해줘
> git status를 확인해줘
```

### 이미지 분석

멀티모달을 지원합니다.

```
> screenshot.png 파일을 보고 UI에서 문제점을 찾아줘
```

---

## 5. 권한 모드

| 모드 | 설명 |
|------|------|
| 기본 모드 | 모든 도구 사용 전 승인 요청 |
| `--allowedTools` | 특정 도구만 자동 승인 |
| `--dangerously-skip-permissions` | 모든 권한 생략 (CI/자동화용) |

```bash
claude --allowedTools Bash,Edit
```

---

## 6. 슬래시 명령어와 단축키

### 슬래시 명령어

| 명령어 | 기능 |
|--------|------|
| `/help` | 전체 명령어 안내 |
| `/clear` | 대화 컨텍스트 초기화 |
| `/compact` | 컨텍스트 정리 (토큰 절약) |
| `/cost` | 현재 토큰 비용 확인 |
| `/quit` | Claude Code 종료 |

### 단축키

| 단축키 | 기능 |
|--------|------|
| `Ctrl + C` | 현재 응답 중단 |
| `Ctrl + D` | Claude Code 종료 |
| `↑` / `↓` | 입력 히스토리 탐색 |
| `Shift + Tab` | 여러 줄 입력 모드 |

---

> 질문이나 지시는 구체적일수록 좋습니다. "이 코드 고쳐줘"보다 "이 함수에서 null 체크를 추가해줘"처럼 명확하게 요청하세요.
