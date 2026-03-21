# Claude Code Guide

> **Claude Code**의 설치부터 고급 활용까지, 한국어로 정리한 실전 가이드 모음

Claude Code(AI 코딩 어시스턴트)의 다양한 기능을 실습하고 테스트하기 위한 가이드 문서 저장소입니다.

---

## 목적

- AI 코딩 어시스턴트의 프롬프트 및 도구(Tools) 활용 실습
- 에이전트 기반 코드 작성, 리팩토링, 디버깅 최적의 협업 패턴 발굴
- 안전한 샌드박스 환경에서의 다양한 파이프라인 및 워크플로 실험

---

## 가이드 목차

### Part 1: 시작하기

| 제목 | 설명 |
|------|------|
| [설치 및 실행](./docs/Part1_Getting_Started/Installation_and_Run.md) | Claude Code 설치, 인증, 첫 실행 |
| [기본 사용법](./docs/Part1_Getting_Started/Basic_Usage.md) | 프롬프트 작성, 파일 편집, 기본 명령어 |
| [프로젝트 설정](./docs/Part1_Getting_Started/Project_Setup.md) | CLAUDE.md, 메모리, 프로젝트 구조 설정 |

### Part 2: 핵심 워크플로

| 제목 | 설명 |
|------|------|
| [Git 워크플로](./docs/Part2_Core_Workflow/Git_Workflow.md) | 커밋, PR, 코드 리뷰 자동화 |
| [컨텍스트 윈도우와 비용 최적화](./docs/Part2_Core_Workflow/Context_and_Cost.md) | 토큰 관리, 세션 인수인계, 프롬프트 캐싱 |
| [실전 팁과 모범 사례](./docs/Part2_Core_Workflow/Tips_and_Best_Practices.md) | 프롬프트 패턴, 세션 관리, 자동화, 실수 회피 |

### Part 3: 고급 활용

| 제목 | 설명 |
|------|------|
| [고급 기능 — MCP, 스킬, 훅](./docs/Part3_Advanced/Advanced_Features.md) | MCP 서버, 커스텀 슬래시 명령, 스킬, 훅 |
| [tmux와 에이전트 팀](./docs/Part3_Advanced/Tmux_and_Agent_Teams.md) | 멀티 세션, 에이전트 병렬 실행 |
| [상태 표시줄 커스터마이징](./docs/Part3_Advanced/Status_Line.md) | Status Line 설정과 예제 스크립트 |

### Part 4: 외부 연동

| 제목 | 설명 |
|------|------|
| [NotebookLM CLI 연동](./docs/Part4_Integration/NotebookLM_CLI.md) | nlm CLI로 노트북 자동화 |
| [텔레그램 연동](./docs/Part4_Integration/Telegram_Integration.md) | Channels로 텔레그램에서 Claude 원격 제어 |
| [MoAI-ADK](./docs/Part4_Integration/MoAI_ADK.md) | AI 자율 개발 환경 소개 및 설치 준비 |

---

## 포함된 스킬

이 저장소를 clone하면 아래 스킬이 자동으로 사용 가능합니다:

| 스킬 | 명령어 | 설명 |
|------|--------|------|
| **ClaudeClaw** | `/claudeclaw` | 텔레그램 연동 단계별 설치 가이드 |
| **Session Pack** | `/pack` | 세션 종료 시 메모리 & 핸드오프 자동 정리 |
| **NLM Skill** | `/nlm-skill` | NotebookLM CLI 사용 가이드 |

---

## 빠른 시작

```bash
# 1. 저장소 clone
git clone https://github.com/eda-ginger/Claude-Code-Guide.git
cd Claude-Code-Guide

# 2. Claude Code 실행
claude

# 3. 스킬 사용 예시
/claudeclaw    # 텔레그램 연동 가이드
/pack          # 세션 정리
```

---

## 라이선스

이 프로젝트는 학습 및 실습 목적으로 공개되어 있습니다.
