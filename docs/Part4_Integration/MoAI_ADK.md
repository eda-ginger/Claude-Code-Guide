# MoAI-ADK — AI 자율 개발 환경

이 문서는 **MoAI-ADK(Agentic Development Kit)** 의 개요와 설치 준비 사항을 정리합니다.

> MoAI-ADK는 Claude Code 위에서 동작하는 자율 개발 시스템입니다. 27개 전문 AI 에이전트와 52개 스킬이 협업하여 코드 생성, 테스트, 리팩토링을 자동으로 수행합니다.

---

## MoAI-ADK란?

한마디로 **"Claude Code에게 개발을 맡기는 시스템"** 입니다.

| 항목 | 내용 |
|------|------|
| **개발** | 모두의AI (modu-ai) |
| **언어** | Go 단일 바이너리 (외부 의존성 없음) |
| **지원 언어** | 18개 프로그래밍 언어 자동 감지 |
| **에이전트** | 27개 (Manager 8, Expert 8, Builder 3, Team 8) |
| **스킬** | 52개 |
| **공식 문서** | https://adk.mo.ai.kr |
| **GitHub** | https://github.com/modu-ai/moai-adk |

---

## 핵심 개념: Harness Engineering

기존 방식: 개발자가 코드를 작성하고, AI가 도와줌
MoAI 방식: **AI가 자율적으로 개발**하고, 개발자는 **환경을 설계**함

```
기존:  개발자 → 코드 작성 → AI 보조
MoAI:  개발자 → 환경 설계 → AI 자율 개발 → 검증
```

---

## 주요 기능

### 자동 개발 방법론 선택
- **새 프로젝트** → TDD(테스트 주도 개발) 자동 적용
- **기존 프로젝트** (테스트 커버리지 10% 미만) → DDD(도메인 주도 설계) 자동 적용

### SPEC 기반 개발
1. `/moai plan "기능 설명"` → SPEC 문서 생성
2. `/moai run SPEC-001` → 에이전트 팀이 자동 구현
3. 자가 검증 루프: 코드 작성 → 테스트 → 리팩토링

### GitHub 연동
- `/moai github issues` → 이슈를 에이전트 팀이 자동 수정
- `/moai github pr 123` → 다관점 PR 리뷰

---

## 설치 방법

```bash
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/modu-ai/moai-adk/main/install.sh | bash
```

---

## 주요 명령어 미리보기

| 명령어 | 설명 |
|--------|------|
| `/moai project` | 프로젝트 아키텍처 문서 생성 |
| `/moai plan "기능"` | SPEC 문서 생성 |
| `/moai run SPEC-001` | SPEC 기반 자동 구현 |
| `/moai clean` | 데드코드 제거 및 AI Slop 정리 |
| `/moai github issues` | 이슈 자동 수정 |
| `/moai github pr 123` | PR 리뷰 |

---

## 다음 할 일

- [ ] MoAI-ADK 설치
- [ ] `/moai project`로 프로젝트 초기화
- [ ] 간단한 기능으로 `/moai plan` → `/moai run` 체험
