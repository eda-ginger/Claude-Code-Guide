# 미니 리뷰 프로젝트 시작하기

> 이 문서를 Claude에게 보여주면 미니 리뷰 프로젝트의 작업 공간을 세팅해줍니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 프로젝트 실행 환경 | `claude --version` |

## 1. starter-kit 복사

이 저장소에 포함된 starter-kit을 작업 디렉토리로 복사합니다:

```bash
cp -r docs/Part2-Research/starter-kit ~/my-mini-review
cd ~/my-mini-review
```

## 2. 폴더 구조 이해하기

```
my-mini-review/
├── CLAUDE.md                    # 프로젝트 규칙 (위키 규칙 + 학술 규칙)
├── primary/                     # 읽기 전용 원본
│   ├── paper-list.md            # → 03에서 생성 (최종 논문 리스트)
│   └── papers/                  # → 03에서 저장 (논문 PDF)
├── secondary/                   # LLM이 관리하는 분석 결과·지식 베이스
│   ├── (03 수집 중간 파일)        # → 03에서 생성 (팀원별 검색 결과)
│   ├── index.md                 # → 04에서 생성 (위키 목차)
│   ├── log.md                   # → 04에서 생성 (작업 기록)
│   ├── summaries/               # → 04에서 생성 (논문별 요약)
│   ├── concepts/                # → 04에서 생성 (접근법 통합 페이지)
│   ├── paper_comparison.md      # → 04에서 생성 (비교표 SSOT)
│   └── outline.md               # → 04에서 생성 (논문 아웃라인)
└── work_paper/                  # LaTeX 집필 공간
    ├── main.tex                 # → 05에서 사용 (원고)
    └── references.bib           # → 05에서 사용 (참고문헌)
```

| 폴더 | 역할 | 누가 수정? | 비유 |
|------|------|-----------|------|
| `primary/` | 원본 자료 | 사용자만 (LLM 수정 금지) | 설계 도면 |
| `secondary/` | 분석 결과·지식 베이스 | LLM이 생성·관리 | 실험 노트 |
| `work_paper/` | 최종 원고 | LLM + 사용자 | 작업 책상 |

### 왜 이렇게 나누는가?

- **primary 보호**: Claude가 아웃라인이나 원본을 "개선"한답시고 수정하면 원래 의도가 사라집니다. 원본은 읽기 전용으로 잠급니다.
- **SSOT(Single Source of Truth)**: 비교표가 `secondary/`에 하나만 있으면, 본문과 불일치가 생겼을 때 어디가 맞는지 명확합니다.
- **작업 공간 분리**: `.tex` 파일만 자유롭게 편집. 원본 자료와 섞이지 않습니다.

## 3. CLAUDE.md 확인

starter-kit에 포함된 `CLAUDE.md`에는 두 가지 규칙이 설정되어 있습니다:

### 지식 베이스 규칙 (Karpathy LLM-Wiki)

| 운영 | 설명 |
|------|------|
| Ingest | 논문을 읽고 `secondary/`에 요약·개념 페이지 생성 |
| Query | 위키를 탐색하고 분석 결과를 다시 위키에 저장 (filing back) |
| Lint | 위키 무결성 검사 (모순, 끊어진 링크, 누락 확인) |

### 학술 규칙

| 규칙 | 설명 |
|------|------|
| Hallucination 금지 | 원본 논문에 없는 내용 생성 금지 |
| primary/ 보호 | 읽기 전용, 절대 수정 불가 |
| 인용 관리 | 모든 `\cite{}`에 `.bib` 엔트리 필수, 중복 키 금지 |
| SSOT | `secondary/paper_comparison.md`가 유일한 진실 공급원 |

> 규칙을 자기 프로젝트에 맞게 수정하려면 `CLAUDE.md`를 직접 편집하세요.

## 4. 실습 흐름 미리보기

이 프로젝트에서 02~06 문서를 순서대로 따라갑니다:

| 단계 | 문서 | 하는 일 | 저장 위치 |
|------|------|--------|----------|
| 도구 설치 | [02-notebooklm](./02-notebooklm.md) | nlm CLI 설치·인증 | (도구 설치, 파일 없음) |
| 논문 수집 | [03-collection](./03-collection.md) | 에이전트 팀으로 5편 수집 | `primary/papers/`, `primary/paper-list.md` |
| 지식 정리 | [04-llm-wiki](./04-llm-wiki.md) | 위키 구축 + 비교표·아웃라인 생성 | `secondary/` 전체 |
| 연구 관리 | [05-obsidian](./05-obsidian.md) | Obsidian 대시보드 + 그래프 시각화 | `secondary/dashboard.md` |
| 논문 작성 | [06-paper-writing](./06-paper-writing.md) | LaTeX 미니 리뷰 작성 | `work_paper/` |

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| starter-kit 폴더가 없음 | 저장소를 다시 clone: `git clone https://github.com/eda-ginger/Claude-Code-Guide.git` |
| 복사 후 CLAUDE.md가 안 보임 | `ls -a ~/my-mini-review` — 숨김 파일 확인 |
| 경로가 다름 | `~/my-mini-review` 대신 원하는 경로로 복사 가능 |

---

> 💡 **Tip:** 이 폴더 구조는 미니 리뷰뿐 아니라 서베이, 비교 분석 등 학술 프로젝트에 범용적으로 사용할 수 있습니다. `CLAUDE.md`의 규칙만 자기 프로젝트에 맞게 수정하세요.

→ **다음 단계**: NotebookLM CLI를 설치합니다 — [NotebookLM CLI 연동](./02-notebooklm.md)
