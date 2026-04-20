# Claude Code Guide

<p align="center">
  <strong>Claude Code</strong>의 설치부터 실전 환경 구축까지, 한국어로 정리한 실전 가이드
</p>

<p align="center">
  <a href="https://docs.anthropic.com/en/docs/claude-code"><img src="https://img.shields.io/badge/Claude_Code-Guide-blueviolet" alt="Claude Code"></a>
  <a href="#"><img src="https://img.shields.io/badge/lang-한국어-blue" alt="Korean"></a>
  <a href="#라이선스"><img src="https://img.shields.io/badge/license-MIT-green" alt="License"></a>
</p>

---

Claude Code(터미널 기반 AI 에이전트)의 다양한 기능을 실습하고 테스트하기 위한 가이드 문서 저장소입니다.
입문자부터 고급 사용자까지, 단계별로 Claude Code를 마스터할 수 있도록 구성했습니다.

### 이런 분들에게 추천합니다

| | 대상 |
|:-:|------|
| 🚀 | Claude Code를 처음 설치하고 어디서부터 시작할지 모르는 분 |
| 🔬 | AI 에이전트를 연구나 실무에 도입하고 싶은 분 |
| 📈 | 프롬프트 → 컨텍스트 → 하네스 엔지니어링의 발전 과정에 관심 있는 분 |
| 💰 | Claude Code의 환경 설계와 비용 최적화를 배우고 싶은 분 |

---

## 빠른 시작

```bash
git clone https://github.com/eda-ginger/Claude-Code-Guide.git
cd Claude-Code-Guide
claude
```

> Part 1을 읽고 이론을 익힌 후, Part 2의 문서를 Claude에게 보여주면서 실습을 진행하세요.

---

## 가이드 목차

### 📘 Part 1: 기본 가이드

> Claude Code의 개념과 사용법을 읽고 이해하는 이론 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [AI 에이전트와 Claude Code](./docs/Part1-Basic/01-agent.md) | AI 에이전트 개념, 강점/약점, Claude Code 설치 |
| 02 | [프로젝트 설정](./docs/Part1-Basic/02-project.md) | CLAUDE.md, 메모리, 스킬, MCP, Hook |
| 03 | [세션 활용법](./docs/Part1-Basic/03-session.md) | 컨텍스트 관리, 비용 최적화, 모델 선택 |

### 📗 Part 2: 연구·학습 활용

> Claude Code를 연구 및 학습 워크플로에 활용하는 실행 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 00 | [Claude Dashboard 설정](./docs/Part2-Research/00-dashboard.md) | claude-dashboard 플러그인 설치 + 커스텀 테마 적용 |
| 01 | [미니 리뷰 프로젝트 시작하기](./docs/Part2-Research/01-starter.md) | 선택 설치, starter-kit 복사, 폴더 구조, 실습 흐름 |
| 02 | [NotebookLM CLI 연동](./docs/Part2-Research/02-notebooklm.md) | nlm CLI 설치·인증·Skill 등록 |
| 03 | [에이전트 팀 문헌 수집](./docs/Part2-Research/03-collection.md) | arXiv + DBLP 에이전트 팀으로 논문 3편 수집·선별 |
| 04 | [LLM-Wiki — 논문 지식 베이스](./docs/Part2-Research/04-llm-wiki.md) | Karpathy 방식으로 비교표·아웃라인 생성 |
| 05 | [Obsidian으로 연구 관리](./docs/Part2-Research/05-obsidian.md) | 대시보드·Graph View로 위키 시각화·추적 |
| 06 | [학술 논문 쓰기](./docs/Part2-Research/06-paper-writing.md) | LaTeX 미니 리뷰 논문 작성 실습 |

### 📙 Part 3: 일상·생활 활용

> Claude Code를 일상생활과 다양한 서비스에 활용하는 실행 문서

| # | 제목 | 설명 |
|:-:|------|------|
| 01 | [발표 자료 생성](./docs/Part3-Life/01-presentation.md) | Marp PDF 슬라이드 제작, NotebookLM 활용 |
| 02 | [Gmail 피드 + Obsidian 대시보드](./docs/Part3-Life/02-gmail-feed.md) | Gmail 뉴스레터 자동 수집, Obsidian 대시보드 구축 |
| 03 | [k-skill — 한국 생활 스킬](./docs/Part3-Life/03-k-skill.md) | SRT 예매, 택배 조회, 미세먼지 등 25개+ 한국 생활 스킬 |

### 📒 Part 4: 부록 (로컬 전용)

> 상세 레퍼런스, 보충 문서. git에 포함되지 않으며 로컬에서만 관리됩니다.

---

## 필수 스킬 설치

이 가이드에서 사용하는 스킬은 직접 설치해야 합니다. 아래 명령으로 한 번에 준비할 수 있습니다:

| 스킬 | 용도 | 설치 명령 | 출처 |
|------|------|-----------|------|
| **k-skill** | 한국 생활 (KTX·택배·미세먼지 등 26개) | `npx --yes skills add NomaDamas/k-skill --all -g` | [NomaDamas/k-skill](https://github.com/NomaDamas/k-skill) |
| **nlm-skill** | NotebookLM CLI 연동 | `nlm skill install claude-code` | [tcsenpai/nlm](https://github.com/tcsenpai/nlm) |
| **session-pack** | 세션 종료 시 메모리·핸드오프 자동 정리 | `curl -sSL https://raw.githubusercontent.com/ten-builder/ten-builder/main/skills/setup.sh \| bash` | [ten-builder](https://github.com/ten-builder/ten-builder) |

> 각 스킬의 상세 사용법은 해당 Part 가이드를 참고하세요. k-skill은 [Part3-03](./docs/Part3-Life/03-k-skill.md), nlm-skill은 [Part2-02](./docs/Part2-Research/02-notebooklm.md).

---

## 프로젝트 구조

```
Claude-Code-Guide/
├── README.md
├── CLAUDE.md                          # 프로젝트 가이드라인
├── .claude/skills/                    # 로컬 스킬 연결 (git 미추적, 위 설치 섹션 참고)
└── docs/
    ├── Part1-Basic/                   # 이론 (3개)
    ├── Part2-Research/                # 연구·학습 실습 (6개)
    │   └── starter-kit/               # 미니 리뷰 프로젝트 템플릿
    └── Part3-Life/                    # 일상·생활 (3개)
        └── seminar/                   # 세미나 발표 자료
```

## 사전 요구사항

| 도구 | 버전 | 비고 |
|------|------|------|
| Node.js | 18+ | `node -v` |
| Claude Code CLI | 최신 | [설치 가이드](./docs/Part1-Basic/01-agent.md) |
| Anthropic 구독 | Pro / Max / API | |

---

## 기여하기

이슈나 개선 사항은 [Issues](https://github.com/eda-ginger/Claude-Code-Guide/issues)에 등록해 주세요. PR도 환영합니다!

## 라이선스

MIT License — 학습 및 실습 목적으로 자유롭게 사용하세요.
