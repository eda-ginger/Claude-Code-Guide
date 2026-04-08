# LLM-Wiki — AI가 관리하는 개인 지식 베이스 구축

> Andrej Karpathy의 LLM Knowledge Base 아이디어를 Claude Code에 적용하여, 코딩 세션에서 자동으로 지식을 축적하는 자가 진화형 메모리 시스템을 구축합니다.

---

## 개요

LLM-Wiki는 복잡한 RAG(검색 증강 생성)나 벡터 데이터베이스 없이, **LLM이 마크다운 문서와 인덱스 파일을 직접 관리**하는 개인용 지식 베이스입니다. Andrej Karpathy가 제안한 이 아이디어는 Claude Code의 Hooks와 Agent SDK를 결합하면 **코딩 세션에서 자동으로 지식을 축적하는 시스템**으로 확장됩니다.

### 핵심 아이디어: 컴파일러 비유

```
소스 코드 (Raw)  →  컴파일러 (LLM)  →  실행 파일 (Wiki)  →  테스트 (Lint)  →  런타임 (Query)
     ↑                    ↑                    ↑                   ↑                  ↑
 원본 문서/기사       LLM이 요약·연결      구조화된 위키       무결성 검사        에이전트가 검색
```

| 단계 | 역할 | 설명 |
|------|------|------|
| Raw (소스 코드) | 원본 진입점 | 기사, 논문, 세션 로그 등 가공 안 된 마크다운 |
| Compiler (컴파일러) | LLM 처리 | 요약 생성, 문서 연결, 지식 구조화 |
| Wiki (실행 파일) | 쿼리 대상 | 개념(concepts) + 연결(connections) + 인덱스 |
| Lint (테스트) | 무결성 검사 | 끊어진 링크, 모순, 오래된 데이터 탐지 |
| Query (런타임) | 검색·답변 | 에이전트가 인덱스를 시작점으로 위키 탐색 |

---

## 사전 요구사항

시작하기 전에 아래 도구들이 준비되어 있는지 확인하세요.

### 필수

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 시스템 실행 환경 | `claude --version` |
| Anthropic 구독 | Claude Code + Agent SDK 사용 | Pro/Max 플랜 |

### 권장

| 도구 | 용도 | 설치 |
|------|------|------|
| Obsidian | 위키 시각화 (그래프 뷰) | [obsidian.md](https://obsidian.md/) (무료) |

> Obsidian은 필수는 아니지만, 지식 그래프를 시각적으로 탐색할 수 있어 강력 추천합니다.

### 사전 확인 명령어

```bash
# Claude Code 설치 확인
claude --version

# Node.js 확인 (Agent SDK용)
node --version  # 18 이상

# Python 확인 (hooks 스크립트용)
python3 --version  # 3.10 이상
```

---

## 아키텍처

### Karpathy 원본 vs Claude Code 적용 버전

| 항목 | Karpathy 원본 | Claude Code 적용 |
|------|---------------|------------------|
| 데이터 소스 | 외부 (웹 기사, 논문) | 내부 (코딩 세션 로그) |
| 수집 방법 | Obsidian Web Clipper | Claude Code Hooks 자동 캡처 |
| 처리 엔진 | LLM 스크립트 | Claude Agent SDK (백그라운드) |
| 저장 형식 | Obsidian 마크다운 | 마크다운 (Obsidian 호환) |
| 활용 | 외부 지식 검색 | 코드베이스 맥락 기억 + 검색 |

### 파일 구조

```
프로젝트/
├── .knowledge/
│   ├── agents.mmd          # 글로벌 규칙 — 에이전트에게 시스템 구조 설명
│   ├── index.mmd           # 파일 목록 — 에이전트의 탐색 시작점
│   ├── daily-logs/         # Raw 데이터 — 세션별 대화 요약
│   │   ├── 2026-04-07.md
│   │   └── 2026-04-08.md
│   └── knowledge/          # Wiki — 컴파일된 지식
│       ├── concepts/       # 핵심 개념 문서
│       └── connections/    # 개념 간 연결 문서
└── .claude/
    └── settings.json       # Hooks 설정
```

### 핵심 파일 역할

**`agents.mmd`** — 에이전트의 메타 인지를 제공하는 글로벌 규칙 파일
- 지식 시스템의 전체 구조를 설명
- 에이전트가 어디서 정보를 찾고, 어떻게 활용해야 하는지 지시

**`index.mmd`** — 에이전트의 탐색 시작점
- 접근 가능한 모든 폴더와 파일 목록
- 벡터 DB 없이도 에이전트가 필요한 정보를 효율적으로 찾아감
- LLM이 자동으로 유지보수 (Karpathy: "fancy RAG가 필요없다")

---

## 동작 원리: Hooks 기반 자동화

```
세션 시작                    세션 진행                     세션 종료/압축
    │                           │                              │
    ▼                           ▼                              ▼
[Session Start Hook]      코딩 작업 + 대화          [Pre-compact / Session End Hook]
    │                                                          │
    ▼                                                          ▼
agents.mmd 로드                                    Agent SDK가 백그라운드 실행
index.mmd 로드                                         │
    │                                                  ▼
    ▼                                          대화 내용 요약 → daily-logs/
에이전트가 지식 시스템 인식                              │
                                                       ▼
                                              [Flush: 1일 1회]
                                              daily-logs → knowledge/ 위키 승격
```

| Hook | 시점 | 동작 |
|------|------|------|
| **Session Start** | 세션 시작 | `agents.mmd` + `index.mmd` 로드 → 에이전트가 지식 시스템 인식 |
| **Pre-compact** | 메모리 압축 전 | Agent SDK로 대화 요약 → daily-logs에 저장 |
| **Session End** | 세션 종료 | Agent SDK로 대화 요약 → daily-logs에 저장 |
| **Flush** | 1일 1회 | daily-logs에서 핵심 개념/연결 추출 → knowledge/ 위키 승격 |

---

## 실습: 직접 구축해보기

### 방법 1: PRD 프롬프트 원샷 설치 (추천)

가장 간단한 방법입니다. Claude Code에 아래 프롬프트를 입력하면 전체 시스템이 자동 구축됩니다.

```
Karpathy의 LLM Knowledge Base 시스템을 이 프로젝트에 구축해줘.

요구사항:
- .knowledge/ 디렉토리에 agents.mmd, index.mmd, daily-logs/, knowledge/ 구조 생성
- Claude Code hooks 설정 (session start, pre-compact, session end)
- Session start hook: agents.mmd와 index.mmd를 컨텍스트에 로드
- Pre-compact/Session end hook: Claude Agent SDK로 대화 요약 → daily-logs에 저장
- Flush 스크립트: daily-logs에서 개념/연결 추출 → knowledge/ 위키에 승격
- 모든 스크립트는 Python으로 작성
- Obsidian 호환 마크다운 형식 (백링크 [[]] 사용)

참고: https://github.com/andrej karpathy의 LLM wiki 아키텍처를 따르되,
외부 데이터 대신 코딩 세션 로그를 소스로 사용
```

> 이 프롬프트 하나로 hooks 설정, 스크립트 생성, 디렉토리 구조까지 한 번에 완성됩니다.

### 방법 2: 수동 단계별 구축

PRD 원샷이 아닌, 직접 이해하면서 단계별로 구축하는 방법입니다.

#### Step 1: 디렉토리 구조 생성

```bash
mkdir -p .knowledge/{daily-logs,knowledge/{concepts,connections}}
```

#### Step 2: agents.mmd 작성

```bash
cat > .knowledge/agents.mmd << 'EOF'
# Knowledge System Rules

## 구조
- `.knowledge/daily-logs/` — 세션별 대화 요약 (Raw 데이터)
- `.knowledge/knowledge/concepts/` — 핵심 개념 문서 (컴파일된 위키)
- `.knowledge/knowledge/connections/` — 개념 간 연결 (백링크)
- `.knowledge/index.mmd` — 탐색 시작점 (파일 목록)

## 규칙
1. 질문을 받으면 먼저 index.mmd를 확인한다
2. 관련 개념 문서를 찾아 읽는다
3. 연결 문서를 통해 관련 지식을 확장한다
4. 새로운 인사이트는 적절한 개념 문서에 추가한다
5. 새 개념이 발견되면 새 문서를 생성하고 index.mmd를 업데이트한다
EOF
```

#### Step 3: index.mmd 작성

```bash
cat > .knowledge/index.mmd << 'EOF'
# Knowledge Index

## 개념 (Concepts)
- (아직 없음 — 세션이 쌓이면 자동 생성됨)

## 연결 (Connections)
- (아직 없음)

## 일일 로그 (Daily Logs)
- (세션 종료 시 자동 추가됨)
EOF
```

#### Step 4: Hooks 설정

`.claude/settings.json`에 hooks를 추가합니다:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "cat .knowledge/agents.mmd .knowledge/index.mmd 2>/dev/null || true"
      }
    ],
    "PreCompact": [
      {
        "type": "command",
        "command": "python3 .knowledge/scripts/capture_session.py"
      }
    ],
    "SessionEnd": [
      {
        "type": "command",
        "command": "python3 .knowledge/scripts/capture_session.py"
      }
    ]
  }
}
```

#### Step 5: 캡처 스크립트 작성

```bash
mkdir -p .knowledge/scripts
```

`.knowledge/scripts/capture_session.py`를 생성합니다:

```python
#!/usr/bin/env python3
"""세션 종료 시 대화 내용을 요약하여 daily-logs에 저장"""
import os
import json
import subprocess
from datetime import datetime

LOG_DIR = os.path.join(os.path.dirname(__file__), "..", "daily-logs")
os.makedirs(LOG_DIR, exist_ok=True)

today = datetime.now().strftime("%Y-%m-%d")
log_file = os.path.join(LOG_DIR, f"{today}.md")

# 최근 대화 내용을 Claude Agent SDK로 요약
# (Agent SDK가 설치되어 있지 않으면 간단한 로그만 남김)
timestamp = datetime.now().strftime("%H:%M")
entry = f"\n## 세션 {timestamp}\n\n- 세션이 기록되었습니다.\n"

with open(log_file, "a", encoding="utf-8") as f:
    f.write(entry)
```

#### Step 6: 테스트

```bash
# Claude Code 실행
claude

# 아무 작업이나 수행 후 세션 종료
# daily-logs/ 에 오늘 날짜 파일이 생성되었는지 확인
ls .knowledge/daily-logs/
```

---

## 실습: 외부 지식 수집 (연구 활용)

코딩 세션 내부 지식뿐 아니라, 외부 연구 자료를 수집하는 데도 활용할 수 있습니다.

### 웹 기사/논문 → Raw 폴더에 추가

```
이 URL의 내용을 .knowledge/daily-logs/에 마크다운으로 저장해줘:
https://example.com/interesting-paper

그리고 핵심 개념을 .knowledge/knowledge/concepts/에 정리해줘
```

### NotebookLM과 연계

```bash
# 1. NotebookLM에 연구 자료 수집
nlm notebook create "My Research"
nlm source add <id> --url "https://paper-url.com"
nlm research start "research topic" --notebook-id <id> --mode deep

# 2. 수집된 지식을 위키로 내보내기
nlm notebook query <id> "핵심 개념을 마크다운으로 정리해줘"

# 3. 결과를 .knowledge/에 저장
# (Claude Code에서 직접 파일로 저장)
```

---

## RAG vs LLM-Wiki 비교

| 항목 | RAG | LLM-Wiki |
|------|-----|----------|
| 처리 시점 | 질의 시점 (Query time) | 수집 시점 (Ingest time) |
| 인프라 | 벡터 DB + 임베딩 파이프라인 | 마크다운 파일 + 인덱스 |
| 적합 규모 | 대규모 (수백만 토큰) | 소~중규모 (~100K 토큰) |
| 검색 정확도 | 유사도 기반 (조용한 실패 가능) | 직접 탐색 (100% 신뢰) |
| 설치 복잡도 | 높음 | 낮음 (파일만 있으면 됨) |
| 토큰 효율 | 보통 | 최대 95% 절감 가능 |

> **결론**: 소규모 개인 지식은 LLM-Wiki, 대규모 동적 데이터는 RAG, 실무에서는 **하이브리드** 추천.

---

## 관련 오픈소스 프로젝트

| 프로젝트 | 특징 | GitHub |
|----------|------|--------|
| **Karpathy LLM-Wiki** | 원본 아키텍처. PRD 프롬프트 제공 | [gist](https://gist.github.com/karpathy) |
| **agentmemory** | BM25 + 벡터 + 지식 그래프 트리플 검색. 에빙하우스 망각 곡선 적용 | [rohitg00/agentmemory](https://github.com/rohitg00/agentmemory) |
| **graphify** | 파일 폴더 → 지식 그래프 변환. Claude Code 스킬 | [safishamsi/graphify](https://github.com/safishamsi/graphify) |

---

## 주의사항과 한계

### 스케일링 한계
- 페이지가 **100~200개를 넘으면** index.mmd가 컨텍스트 창을 가득 채움
- 대규모에서는 로컬 하이브리드 검색(BM25 + Vector) 엔진 연동 필요

### 지식 오염 (Knowledge Drift)
- LLM의 잘못된 추론이 위키에 병합되면 이후 업데이트에 오류가 누적
- **대책**: Git 버전 관리 + 주기적 자동 린팅 + 무결성 검증

### 출처 손실
- 요약·압축 과정에서 원본 출처의 세부사항이 소실될 수 있음
- **대책**: 각 문서의 YAML Frontmatter에 원본 출처 링크 필수 태깅

### 인지적 한계
- AI가 정리해주면 인간이 직접 구조화하며 얻는 "이해의 과정"이 생략됨
- 중요한 연구는 AI 정리 결과를 **직접 리뷰하고 수정**하는 과정 권장

---

## 참고 자료

- 원본 영상: [I Built Self-Evolving Claude Code Memory w/ Karpathy's LLM Knowledge Bases](https://www.youtube.com/watch?v=7huCP6RkcY4)
- Karpathy 원본 트윗 및 PRD 프롬프트: [gist](https://gist.github.com/karpathy)
- Claude Code Hooks 문서: [docs.anthropic.com](https://docs.anthropic.com/en/docs/claude-code/hooks)
- Claude Agent SDK: [docs.anthropic.com](https://docs.anthropic.com/en/docs/claude-code/sdk)
- NotebookLM 연구 노트북: `LLM-Wiki-Research` (nlm alias: `llm-wiki`)
