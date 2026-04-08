# Claude Code Guide

> **Claude Code**의 설치부터 실전 환경 구축까지, 한국어로 정리한 실전 가이드 모음

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
    ├── Part1-Basic/                  # 기본 가이드 (읽고 이해)
    ├── Part2-Setup/                  # 실전 환경 구축
    ├── Part3-Research/               # 연구·학습 활용
    ├── Part4-Life/                   # 일상·생활 활용
    └── Part5-Reference/              # 부록·레퍼런스
```

---

## 가이드 목차

### Part 1: 기본 가이드

> Claude Code의 개념과 사용법을 읽고 이해하는 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [설치와 기본 사용법](./docs/Part1-Basic/01-start.md) | 설치, 인증, 첫 실행, 프롬프트, 명령어, 단축키 |
| 02 | [프로젝트 설정](./docs/Part1-Basic/02-project.md) | CLAUDE.md, 메모리, 프로젝트 구조 설정 |
| 03 | [비용 최적화와 모범 사례](./docs/Part1-Basic/03-tips.md) | 컨텍스트 관리, 프롬프트 작성법, 비용 절감, 세션 인수인계 |

### Part 2: 실전 환경 구축

> Claude에게 문서를 보여주면 환경을 세팅하고 사용법까지 안내하는 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [고급 기능 — MCP, 스킬, 훅](./docs/Part2-Setup/01-advanced.md) | MCP 서버, 스킬, 훅, Status Line |
| 02 | [멀티 머신 병렬 작업](./docs/Part2-Setup/02-multisession.md) | Worktree + Hook + PR 조합으로 충돌 없는 병렬 작업 |
| 03 | [tmux와 에이전트 팀](./docs/Part2-Setup/03-tmux.md) | 멀티 세션, 에이전트 병렬 실행 |

### Part 3: 연구·학습 활용

> Claude Code를 연구 및 학습 워크플로에 활용하는 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [NotebookLM CLI 연동](./docs/Part3-Research/01-notebooklm.md) | nlm CLI로 노트북 자동화 |
| 02 | [에이전트 팀 문헌 자동 수집](./docs/Part3-Research/02-research.md) | Agent Teams로 논문 수집 + PDF 다운로드 자동화 |
| 03 | [LLM-Wiki — AI 지식 베이스 구축](./docs/Part3-Research/03-llm-wiki.md) | Karpathy's LLM-Wiki + Claude Code Hooks로 자가 진화형 메모리 |
| 04 | [학술 논문 쓰기](./docs/Part3-Research/04-paper-writing.md) | LaTeX + CLAUDE.md로 미니 리뷰 논문 작성 실습 (스타터 킷 포함) |

### Part 4: 일상·생활 활용

> Claude Code를 일상생활과 다양한 서비스에 활용하는 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [대학원생의 Obsidian 볼트](./docs/Part4-Life/01-obsidian-vault.md) | PARA 구조, Dashboard, Gmail 뉴스레터 피드 파이프라인 |
| 02 | [k-skill — 한국 생활 스킬](./docs/Part4-Life/02-k-skill.md) | SRT 예매, 택배 조회, 미세먼지 등 25개+ 한국 생활 스킬 |

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

Part 1을 읽고 기본을 익힌 후, Part 2의 문서를 Claude에게 보여주면서 환경을 구축해보세요.

---

## 사전 요구사항

- **Node.js** 18 이상
- **Claude Code CLI** ([설치 가이드](./docs/Part1-Basic/01_Installation_and_Run.md))
- **Anthropic 구독** (Pro, Max, 또는 API 키)

---

## 기여하기

이슈나 개선 사항은 [Issues](https://github.com/eda-ginger/Claude-Code-Guide/issues)에 등록해 주세요. PR도 환영합니다!

---

## 라이선스

이 프로젝트는 학습 및 실습 목적으로 공개되어 있습니다. MIT License.
