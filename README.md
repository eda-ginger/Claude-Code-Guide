# Claude Code Guide

> **Claude Code**의 설치부터 고급 활용까지, 한국어로 정리한 실전 가이드 모음

[![Claude Code](https://img.shields.io/badge/Claude_Code-Guide-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![Korean](https://img.shields.io/badge/lang-한국어-blue)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](#라이선스)

Claude Code(AI 코딩 어시스턴트)의 다양한 기능을 실습하고 테스트하기 위한 가이드 문서 저장소입니다. 입문자부터 고급 사용자까지, 단계별로 Claude Code를 마스터할 수 있도록 구성했습니다.

---

## 이런 분들에게 추천합니다

- Claude Code를 처음 설치하고 어디서부터 시작할지 모르는 분
- AI 코딩 어시스턴트를 실무에 도입하고 싶은 개발자
- 프롬프트 엔지니어링과 에이전트 워크플로에 관심 있는 분
- Claude Code의 비용을 최적화하고 싶은 분

---

## 프로젝트 구조

```
Claude-Code-Guide/
├── README.md                          # 이 파일
├── CLAUDE.md                          # 프로젝트 가이드라인
├── .gitignore
├── .claude/
│   └── skills/                        # 내장 스킬 (clone 시 자동 포함)
│       ├── claudeclaw/                # 텔레그램 연동 가이드
│       ├── session-pack/              # 세션 자동 정리
│       └── nlm-skill/                 # NotebookLM CLI 가이드
└── docs/
    ├── Part1_Getting_Started/         # 시작하기
    ├── Part2_Core_Workflow/           # 핵심 워크플로
    ├── Part3_Advanced/                # 고급 활용
    └── Part4_Integration/             # 외부 연동
```

---

## 가이드 목차

### Part 1: 시작하기

> Claude Code 설치부터 첫 프로젝트 설정까지

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [설치 및 실행](./docs/Part1_Getting_Started/01_Installation_and_Run.md) | Claude Code 설치, 인증, 첫 실행 |
| 02 | [기본 사용법](./docs/Part1_Getting_Started/02_Basic_Usage.md) | 프롬프트 작성, 파일 편집, 기본 명령어 |
| 03 | [프로젝트 설정](./docs/Part1_Getting_Started/03_Project_Setup.md) | CLAUDE.md, 메모리, 프로젝트 구조 설정 |

### Part 2: 핵심 워크플로

> 일상적인 개발 작업에 Claude Code를 활용하는 패턴

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [Git 워크플로](./docs/Part2_Core_Workflow/01_Git_Workflow.md) | 커밋, PR, 코드 리뷰 자동화 |
| 02 | [컨텍스트 윈도우와 비용 최적화](./docs/Part2_Core_Workflow/02_Context_and_Cost.md) | 토큰 관리, 세션 인수인계, 프롬프트 캐싱 |
| 03 | [실전 팁과 모범 사례](./docs/Part2_Core_Workflow/03_Tips_and_Best_Practices.md) | 프롬프트 패턴, 세션 관리, 자동화, 실수 회피 |

### Part 3: 고급 활용

> Claude Code의 확장 기능과 파워 유저 팁

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [고급 기능 — MCP, 스킬, 훅](./docs/Part3_Advanced/01_Advanced_Features.md) | MCP 서버, 커스텀 슬래시 명령, 스킬, 훅 |
| 02 | [tmux와 에이전트 팀](./docs/Part3_Advanced/02_Tmux_and_Agent_Teams.md) | 멀티 세션, 에이전트 병렬 실행 |
| 03 | [상태 표시줄 커스터마이징](./docs/Part3_Advanced/03_Status_Line.md) | Status Line 설정과 테마 |

### Part 4: 외부 연동

> Claude Code를 다른 서비스와 연결하여 확장하기

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [NotebookLM CLI 연동](./docs/Part4_Integration/01_NotebookLM_CLI.md) | nlm CLI로 노트북 자동화 |
| 02 | [텔레그램 연동](./docs/Part4_Integration/02_Telegram_Integration.md) | Channels로 텔레그램에서 Claude 원격 제어 |
| 03 | [MoAI-ADK](./docs/Part4_Integration/03_MoAI_ADK.md) | AI 자율 개발 환경 소개 및 설치 준비 |

---

## 포함된 스킬

이 저장소를 clone하면 아래 스킬이 자동으로 사용 가능합니다:

| 스킬 | 명령어 | 설명 |
|------|--------|------|
| **ClaudeClaw** | `/claudeclaw` | 텔레그램 연동 단계별 설치 가이드 |
| **Session Pack** | `/pack` | 세션 종료 시 메모리 & 핸드오프 자동 정리 |
| **NLM Skill** | `/nlm-skill` | NotebookLM CLI 사용 가이드 |

> 스킬은 `.claude/skills/` 디렉토리에 위치하며, Claude Code 실행 시 자동으로 인식됩니다.

---

## 빠른 시작

### 1. 저장소 clone

```bash
git clone https://github.com/eda-ginger/Claude-Code-Guide.git
cd Claude-Code-Guide
```

### 2. Claude Code 실행

```bash
claude
```

### 3. 스킬 사용해 보기

```bash
/claudeclaw    # 텔레그램 연동 가이드
/pack          # 세션 종료 시 자동 정리
```

### 4. 가이드 따라하기

Part 1부터 순서대로 읽어보세요. 각 문서는 독립적으로도 참고할 수 있습니다.

---

## 사전 요구사항

- **Node.js** 18 이상
- **Claude Code CLI** ([설치 가이드](./docs/Part1_Getting_Started/01_Installation_and_Run.md))
- **Anthropic 구독** (Pro, Max, 또는 API 키)

---

## 기여하기

이슈나 개선 사항은 [Issues](https://github.com/eda-ginger/Claude-Code-Guide/issues)에 등록해 주세요. PR도 환영합니다!

---

## 라이선스

이 프로젝트는 학습 및 실습 목적으로 공개되어 있습니다. MIT License.
