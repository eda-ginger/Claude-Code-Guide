# Claude Code로 학술 논문 쓰기

> 미리 준비된 재료(아웃라인, 비교표, LaTeX 템플릿)를 Claude Code와 함께 학술 논문으로 완성하는 실습 가이드
>
> **예제 주제**: LLM-Based Code Generation 미니 리뷰 (3편 논문 비교)

---

## 이런 상황에서 사용합니다

- 학술 논문(리뷰, 서베이 등)을 LaTeX로 작성할 때
- 분석 데이터를 본문과 일관성 있게 관리하고 싶을 때
- 인용 누락, 수치 오류 같은 실수를 자동으로 잡고 싶을 때
- Claude Code에게 학술 글쓰기의 규칙을 인식시키고 싶을 때

---

## 사전 준비

이 가이드의 모든 작업은 **Claude Code 세션 안에서** 수행합니다. 터미널을 별도로 열 필요가 없습니다.

### 실습 시작

Claude-Code-Guide를 clone하고 Claude Code를 실행합니다:

```bash
git clone https://github.com/eda-ginger/Claude-Code-Guide.git
cd Claude-Code-Guide
claude
```

Claude Code 세션에 들어왔으면, 아래 내용을 **Claude에게 요청**하세요.

### LaTeX 환경 설치

Claude Code 세션에서 Claude에게 요청합니다:

```
pdflatex가 설치되어 있는지 확인하고, 없으면 설치해줘.
texlive-latex-base, texlive-latex-extra, texlive-fonts-recommended,
texlive-bibtex-extra 패키지가 필요해.
설치 후 테스트 컴파일도 해줘.
```

Claude가 알아서 OS를 판단하고 설치합니다:

- **Ubuntu/WSL**: `sudo apt install texlive-latex-base ...`
- **macOS**: `brew install --cask basictex && sudo tlmgr install natbib booktabs`

> **참고**: `sudo` 명령은 Claude Code가 실행 전에 승인을 요청합니다. 확인 후 허용하면 됩니다.

### 스타터 킷 세팅

LaTeX 설치가 끝났으면, 실습 프로젝트를 세팅합니다:

```
docs/Part3-Research/starter-kit/ 을 ~/my-mini-review 로 복사하고
그 폴더로 이동해줘.
```

복사된 구조:

```
~/my-mini-review/
├── CLAUDE.md                        # 학술 프로젝트 규칙
├── primary/
│   ├── outline.md                   # 리뷰 아웃라인
│   └── papers/                      # 논문 PDF (아래에서 다운로드)
├── secondary/
│   └── paper_comparison.md          # 3편 비교표
└── work_paper/
    ├── main.tex                     # LaTeX 템플릿
    └── references.bib               # BibTeX 엔트리
```

### 논문 PDF 다운로드

논문 3편을 Claude에게 다운로드시킵니다:

```
다음 3편의 논문 PDF를 primary/papers/ 에 다운로드해줘:
1. https://arxiv.org/pdf/2107.03374 → codex_2021.pdf
2. https://arxiv.org/pdf/2203.07814 → alphacode_2022.pdf
3. https://arxiv.org/pdf/2308.12950 → codellama_2023.pdf
```

> **참고**: arXiv PDF는 `curl`이나 `wget`으로 바로 받을 수 있어서 Claude가 처리할 수 있습니다.

### 프로젝트 전환

다운로드까지 끝났으면, 실습 프로젝트로 Claude Code 세션을 새로 엽니다:

```bash
# 현재 세션을 나가고
/exit

# 실습 프로젝트에서 새 세션 시작
cd ~/my-mini-review
claude
```

이제 Claude Code가 `CLAUDE.md`를 자동으로 읽고, 학술 규칙이 적용된 상태로 시작됩니다.

---

## Step 1: 프로젝트 세팅 이해하기

### 폴더 구조의 의미

학술 프로젝트에서 파일을 **역할별로 분리**하는 것이 핵심입니다:

```
my-mini-review/
├── CLAUDE.md          # Claude Code에게 주는 규칙서
├── primary/           # 절대 수정 불가 — 프로젝트의 "헌법"
│   ├── outline.md     # 논문 구조 (확정된 설계도)
│   └── papers/        # 원본 논문 PDF
├── secondary/         # 분석 결과 — 근거 자료
│   └── paper_comparison.md
└── work_paper/        # 실제 집필 공간
    ├── main.tex
    └── references.bib
```

| 폴더 | 역할 | 수정 가능? | 비유 |
|------|------|-----------|------|
| `primary/` | 원본 자료, 확정된 설계 | 절대 불가 | 설계 도면 |
| `secondary/` | 분석 데이터, 비교표 | 분석 업데이트 시만 | 실험 노트 |
| `work_paper/` | 활성 원고 | 자유롭게 | 작업 책상 |

**왜 이렇게 나누는가?**

- **primary 보호**: Claude가 아웃라인을 "개선"한답시고 구조를 바꾸면 원래 의도가 사라집니다. 아웃라인은 사용자가 확정한 것이므로 수정 불가로 잠급니다.
- **SSOT(Single Source of Truth)**: 비교표가 `secondary/`에 하나만 있으면, 본문 테이블과 불일치가 생겼을 때 어디가 맞는지 명확합니다.
- **작업 공간 분리**: `.tex` 파일만 자유롭게 편집. 원본 자료와 섞이지 않습니다.

### CLAUDE.md 핵심 규칙 살펴보기

스타터 킷의 `CLAUDE.md`를 열어보면 학술 프로젝트에 필요한 규칙이 설정되어 있습니다:

```
CLAUDE.md를 읽어줘. 어떤 규칙이 있는지 요약해줘.
```

주요 규칙을 하나씩 살펴보겠습니다.

#### 규칙 1: Hallucination 금지

```markdown
# CLAUDE.md 에서 발췌
- **No Hallucinations**: Do not fabricate claims, inflate results,
  or generate text not supported by the source papers in `primary/papers/`.
```

학술 글쓰기에서 가장 중요한 규칙입니다. 이 규칙이 없으면 Claude가 그럴듯하지만 **논문에 없는 내용**을 만들어낼 수 있습니다.

예를 들어 "Codex achieved 95% accuracy" 같은 문장을 생성할 수 있는데, 실제로는 28.8%입니다. CLAUDE.md에 이 규칙을 명시하면 Claude가 수치를 쓸 때 원본 논문을 확인합니다.

#### 규칙 2: primary/ 보호

```markdown
- **`primary/` Folder**: NEVER edit or delete files in this directory.
```

Claude에게 도구(Edit, Write) 사용 시 `primary/` 경로를 건드리지 말라고 명시합니다. 이게 없으면 Claude가 "아웃라인을 좀 더 좋게 수정해드렸습니다"라고 할 수 있습니다.

#### 규칙 3: 원고 편집 승인

```markdown
- Modifications to `main.tex` require **prior discussion and user confirmation**
  for major structural changes.
```

섹션 추가/삭제 같은 큰 변경은 Claude가 먼저 제안하고, 사용자가 승인한 뒤에 실행합니다. 소소한 수정(오타, 인용 추가)은 바로 해도 됩니다.

#### 규칙 4: BibTeX 관리

```markdown
- Check for **duplicate Citation Keys** in `references.bib` before adding new entries.
- Every `\cite{}` must have a corresponding entry in `references.bib`.
```

논문이 늘어나면 같은 논문을 다른 키로 두 번 넣거나, 인용은 했는데 `.bib`에 안 넣는 실수가 생깁니다. 이 규칙으로 Claude가 자동으로 체크합니다.

#### 자기 프로젝트에 적용하기

이 CLAUDE.md를 자기 프로젝트에 복사해서 사용할 때, 수정할 부분:

| 항목 | 수정 방법 |
|------|----------|
| Project Purpose | 자기 논문의 제목과 목표로 교체 |
| Project Structure | 자기 폴더 구조에 맞게 경로 수정 |
| Comparison Table | 자기 분석 테이블의 SSOT 경로로 교체 |
| 나머지 규칙 | 그대로 사용 가능 (범용적) |

---

## Step 2: 원고 작성

이제 Claude Code와 함께 실제로 논문을 쓰겠습니다.

### 2-1. 아웃라인 기반 초안 작성

Claude Code에서 아웃라인을 읽히고, 섹션별로 초안을 요청합니다:

```
primary/outline.md 읽고, Section 1 (Introduction) 초안을 main.tex에 작성해줘.
primary/papers/ 에 있는 3편 논문을 참고해서 써줘.
```

**팁: 섹션 단위로 요청하세요.**

한 번에 "전체 논문 써줘"보다 섹션별로 나눠서 요청하는 게 품질이 높습니다:

```
# 좋은 예 (섹션별)
Section 2 (Background) 초안을 써줘. outline.md의 Section 2를 따라가되,
pass@k 메트릭과 HumanEval 벤치마크 설명에 집중해줘.

# 피할 예 (한번에 전체)
논문 전체를 써줘.
```

### 2-2. 비교표를 LaTeX 테이블로 변환

`secondary/paper_comparison.md`의 비교표를 LaTeX 테이블로 변환합니다:

```
secondary/paper_comparison.md의 Table 1을 LaTeX booktabs 테이블로 변환해서
main.tex의 Section 4에 넣어줘. 모든 수치가 비교표와 정확히 일치하는지 확인해줘.
```

Claude가 변환한 결과를 SSOT(비교표)와 대조해서 확인합니다. CLAUDE.md에 규칙이 있으므로 Claude도 자동으로 대조합니다.

### 2-3. 인용 삽입

논문을 쓰면서 인용을 추가합니다:

```
Section 3.1 (Codex)에서 주요 수치를 인용할 때 \cite{chen2021codex}를 사용해줘.
HumanEval 결과는 반드시 원본 논문의 Table 1에서 가져와줘.
```

새로운 참고문헌이 필요하면:

```
이 논문도 인용하고 싶어: "Language Models are Few-Shot Learners" (Brown et al., 2020).
references.bib에 엔트리 추가하고 본문에서 인용해줘.
기존 키와 중복되지 않는지 확인하고.
```

### 2-4. PDF 컴파일

원고를 PDF로 컴파일합니다:

```
main.tex를 컴파일해서 PDF 만들어줘.
```

Claude Code가 실행하는 명령:

```bash
cd work_paper
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

> **왜 3번 실행하나요?**
> 1차: `.aux` 파일 생성 (인용 정보 수집)
> `bibtex`: `.bib`에서 참고문헌 목록 생성
> 2차: 참고문헌 목록 삽입
> 3차: 참조 번호 확정 (cross-reference 해소)

컴파일 에러가 나면 Claude Code가 로그를 읽고 수정합니다:

```
컴파일 에러가 났어. main.log 읽고 고쳐줘.
```

흔한 에러와 해결:

| 에러 | 원인 | Claude에게 요청 |
|------|------|----------------|
| `Undefined control sequence` | 패키지 미설치 또는 오타 | "이 에러 고쳐줘" |
| `Citation undefined` | `.bib`에 키가 없음 | "references.bib에 빠진 엔트리 추가해줘" |
| `Missing $ inserted` | 수식 밖에서 `_` 사용 | "수식 기호 이스케이프 처리해줘" |

---

## Step 3: 검증

원고 초안이 완성되면 품질을 검증합니다.

### 3-1. 인용 누락 체크

```
main.tex에서 사실적 주장(숫자, 성능, 비교)을 하면서 \cite{}가 없는 곳을 찾아줘.
```

Claude가 본문을 스캔해서 인용이 빠진 문장을 찾아줍니다. 예:

```
발견된 인용 누락:
- Line 45: "Codex achieved 28.8% on HumanEval" → \cite{chen2021codex} 필요
- Line 78: "competitive programming problems" → \cite{li2022alphacode} 필요
```

### 3-2. 비교표 vs 본문 일관성

```
secondary/paper_comparison.md의 수치와 main.tex 본문의 수치가 일치하는지 전수 검사해줘.
```

SSOT(비교표)와 본문에서 같은 수치를 다르게 쓰고 있지 않은지 확인합니다. 예:

```
불일치 발견:
- 비교표: "HumanEval pass@1 = 28.8%" / 본문 Line 52: "approximately 29%"
  → 정확한 수치로 통일 권장
```

### 3-3. BibTeX 정합성

```
references.bib의 모든 엔트리가 main.tex에서 인용되고 있는지,
반대로 main.tex의 모든 \cite{}가 references.bib에 있는지 교차 확인해줘.
```

### 3-4. 최종 컴파일 + 확인

```
최종 컴파일 한 번 더 해줘. warning 없이 깨끗하게 빌드되는지 확인하고,
warning이 있으면 알려줘.
```

---

## 실전 팁

### CLAUDE.md 규칙은 구체적으로

```markdown
# 나쁜 예 (모호함)
- Be careful with citations.

# 좋은 예 (구체적)
- Every factual claim must have a \cite{}.
- Do not fabricate results not in the source papers.
- Check for duplicate Citation Keys before adding.
```

모호한 규칙은 Claude가 자의적으로 해석합니다. 구체적인 행동 지시가 효과적입니다.

### 대규모 프로젝트로 확장할 때

이 가이드는 3편으로 실습했지만, 실제 리뷰 논문은 수십~수백 편을 다룹니다. 확장 시 추가로 필요한 것:

| 규모 | 추가 사항 |
|------|----------|
| 10~30편 | `secondary/`에 분석표 SSOT 관리, Step별 분석 파일 분리 |
| 30~100편 | 에이전트 팀으로 논문 분석 병렬화 ([에이전트 팀 문헌 수집](./02-research.md) 참고) |
| 100편+ | 큐레이션 파이프라인 (에이전트 검증 → 사용자 선별), Supplementary Table 분리 |

### Hallucination 탐지 프롬프트 모음

학술 글쓰기에서 유용한 검증 프롬프트:

```
# 사실 확인
"방금 쓴 Section 3에서 모든 수치의 출처를 논문명+페이지로 알려줘"

# 과장 표현 탐지
"본문에서 'significantly', 'dramatically', 'clearly superior' 같은
과장 표현을 찾아서, 데이터로 뒷받침되는지 확인해줘"

# 누락 확인
"outline.md와 비교해서, 본문에서 빠진 포인트가 있는지 확인해줘"
```

---

## 체크리스트

실습을 마친 후 확인:

- [ ] `primary/` 폴더는 수정되지 않았는가?
- [ ] 본문의 모든 수치가 `secondary/paper_comparison.md`와 일치하는가?
- [ ] 모든 `\cite{}`에 대응하는 `.bib` 엔트리가 있는가?
- [ ] 컴파일이 warning 없이 완료되는가?
- [ ] PDF에서 참고문헌 목록이 정상 출력되는가?

---

## 참고 자료

- [에이전트 팀 문헌 자동 수집](./02-research.md) — 논문을 대규모로 수집할 때
- [NotebookLM CLI 연동](./01-notebooklm.md) — 논문 요약과 Deep Research
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX) — LaTeX 기본 문법 참고
- [Overleaf Documentation](https://www.overleaf.com/learn) — LaTeX 패키지 사용법
