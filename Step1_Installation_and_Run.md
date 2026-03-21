# Step 1: Claude Code 설치 및 실행 가이드

이 문서에서는 Anthropic에서 제공하는 공식 CLI 기반 AI 코딩 어시스턴트인 **Claude Code**의 설치 및 기본 실행 방법을 안내합니다.

## 1. 사전 요구사항
Claude Code는 Node.js 환경에서 동작합니다. 따라서 시스템에 **Node.js 18 이상** 버전이 설치되어 있어야 하며, 패키지 매니저인 `npm` 명령어를 사용할 수 있어야 합니다.
- 설치 여부 확인: 터미널에서 `node -v` 및 `npm -v`를 실행하여 버전이 출력되는지 확인하세요.

### 1.1 Node.js 및 npm 설치 방법 (미설치 시)
만약 `npm`을 아예 사용할 수 없거나 명령어를 찾을 수 없다는 에러가 뜬다면, 아래의 단계에 따라 Node.js를 설치해야 합니다.

**[옵션 A] 공식 홈페이지를 통한 직접 설치 (가장 확실함)**
1. [Node.js 공식 홈페이지(nodejs.org)](https://nodejs.org/)에 접속합니다.
2. 가장 안정적인 **LTS (Long Term Support)** 버전 버튼을 클릭하여 설치 파일(Windows의 경우 `.msi`)을 다운로드합니다.
3. 다운로드한 설치 프로그램을 실행하고 계속 'Next(다음)'를 눌러 설치를 완료합니다. 
   *(이 과정에서 `npm` 패키지 매니저가 자동으로 함께 설치되며, 환경 변수-PATH에도 체크되어 등록됩니다.)*

**[옵션 B] NVM(Node Version Manager)을 통한 설치 (버전 관리용)**
앞으로 여러 가지 Node 버전(예: 18, 20, 22 등)을 번갈아 쓰실 계획이라면 NVM 사용을 적극 권장합니다.
1. Windows 사용자라면 [nvm-windows 릴리스 페이지](https://github.com/coreybutler/nvm-windows/releases)에 접속하여 `nvm-setup.exe`를 다운로드 및 설치합니다.
2. 설치 완료 후 **터미널을 관리자 권한으로 열고** 아래 2개의 명령어를 순서대로 입력합니다.
   ```bash
   nvm install lts   # 최신 안정화(LTS) 버전 다운로드
   nvm use lts       # 다운로드한 버전을 현재 시스템에 적용
   ```

> ⚠️ **주의:** Node.js 설치 또는 NVM 설정을 마치셨다면 **열려있는 모든 터미널 창을 껐다가 새로 열어야** 방금 등록된 `npm` 명령어가 정상적으로 동작합니다!

## 2. Claude Code 설치하기
Node.js 준비가 끝났다면 터미널(또는 명령 프롬프트)을 열고 아래 명령어를 실행하여 전역(Global)으로 설치합니다.

```bash
npm install -g @anthropic-ai/claude-code
```

설치가 완료되면 `claude --version`을 입력하여 정상적으로 설치되었는지 확인합니다.

## 3. 실행 및 인증 (Authentication)
설치가 끝난 후 터미널에 아래 명령어를 입력하여 Claude Code를 실행합니다.

```bash
claude
```

**첫 실행 시 인증 과정:**
1. 명령어를 입력하면 브라우저가 열리면서 Anthropic Console 권한 인증 페이지로 이동합니다.
2. Anthropic 계정으로 로그인하고 CLI 접근 권한을 허용(Approve)합니다.
3. 인증이 완료되면 터미널 창으로 돌아와 `>` 프롬프트가 표시되며 언제든 Claude와 대화하고 명령을 내릴 수 있습니다.

## 4. 유용한 기본 명령어 (Commands)
Claude Code 내에서 사용할 수 있는 몇 가지 편리한 `/` (슬래시) 명령어입니다.
- `/help`: 전체 명령어와 사용법 안내를 확인합니다.
- `/clear`: 현재 대화 컨텍스트를 비우고 새로 시작합니다.
- `/compact`: 대화 내역의 쓸데없는 텍스트를 정리하여 컨텍스트 메모리(토큰)를 아낍니다.
- `/cost`: 현재까지 사용한 API 토큰 비용을 확인합니다.
- `/quit` 또는 `exit`: Claude Code를 종료합니다.

---
> 💡 **Tip:** Claude Code는 터미널 기반이므로, 현재 작업 중인 프로젝트 폴더 위치에서 `claude`를 실행하는 것이 해당 코드를 분석하고 수정하는 데 가장 효율적입니다.
