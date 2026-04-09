# Claude Code로 학술 논문 쓰기

> 이 문서를 Claude에게 보여주면 04에서 만든 비교표와 아웃라인을 바탕으로 LaTeX 미니 리뷰 논문을 작성해줍니다.
>
> **예제 주제**: LLM-Based Code Generation 미니 리뷰 (3편 논문 비교)

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 논문 작성 실행 | `claude --version` |
| 04에서 만든 산출물 | 비교표 + 아웃라인 | `ls secondary/paper_comparison.md secondary/outline.md` |

> [LLM-Wiki 지식 베이스](./04-llm-wiki.md)를 먼저 완료하세요. `secondary/`에 비교표, 아웃라인, 논문 요약이 있어야 합니다. [Obsidian](./05-obsidian.md)은 선택 — 위키를 시각적으로 확인하고 싶을 때 사용합니다.


## 1. LaTeX 환경 설치

### pdflatex 설치

Claude Code 세션에서 요청합니다:

```
pdflatex가 설치되어 있는지 확인하고, 없으면 설치해줘.
texlive-latex-base, texlive-latex-extra, texlive-fonts-recommended,
texlive-bibtex-extra 패키지가 필요해.
설치 후 테스트 컴파일도 해줘.
```

Claude가 OS를 판단하고 설치합니다:

- **Ubuntu/WSL**: `sudo apt install texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-bibtex-extra`
- **macOS**: `brew install --cask basictex && sudo tlmgr install natbib booktabs`

> `sudo` 명령은 Claude Code가 실행 전에 승인을 요청합니다.

### VS Code 확장 (선택)

에디터에서 LaTeX를 편집하려면:

| 확장 | 용도 |
|------|------|
| **LaTeX Workshop** | `.tex` 편집, 구문 강조, 미리보기, 자동 컴파일 |
| **LTeX** | 문법·맞춤법 검사 (학술 영어) |

VS Code에서 `Ctrl+Shift+X` → "LaTeX Workshop" 검색 → 설치.

> Antigravity 에디터도 동일한 확장을 사용할 수 있습니다.


## 2. 원고 작성

`starter-kit/work_paper/`에서 작업합니다. 예제 템플릿(`oup-authoring-template.tex`)이 포함되어 있습니다.

### 템플릿 복사

원본 템플릿을 보존하기 위해 `template/`에서 복사하여 작업합니다:

```bash
cp work_paper/template/oup-authoring-template.tex work_paper/main.tex
cp work_paper/template/oup-authoring-template.cls work_paper/
cp work_paper/template/oup-abbrvnat.bst work_paper/
```

이후 모든 작업은 `work_paper/main.tex`에서 진행합니다. `template/` 폴더의 원본은 참고용으로 보존됩니다.

### 아웃라인 기반 초안 작성

04에서 생성한 아웃라인을 기반으로 섹션별로 초안을 요청합니다:

```
secondary/outline.md 읽고, Section 1 (Introduction) 초안을 work_paper/main.tex에 작성해줘.
primary/papers/ 에 있는 3편 논문과 secondary/summaries/ 의 요약을 참고해서 써줘.
```

**섹션 단위로 요청하세요.** 한 번에 "전체 논문 써줘"보다 품질이 높습니다:

```
# 좋은 예 (섹션별)
Section 2 (Background) 초안을 써줘. secondary/outline.md의 Section 2를 따라가되,
pass@k 메트릭과 HumanEval 벤치마크 설명에 집중해줘.

# 피할 예 (한번에 전체)
논문 전체를 써줘.
```

### 비교표를 LaTeX 테이블로 변환

`secondary/paper_comparison.md`의 비교표를 LaTeX 테이블로 변환합니다:

```
secondary/paper_comparison.md를 LaTeX booktabs 테이블로 변환해서
main.tex의 Approaches 섹션에 넣어줘. 모든 수치가 비교표와 정확히 일치하는지 확인해줘.
```

CLAUDE.md에 SSOT 규칙이 있으므로 Claude도 자동으로 대조합니다.

### Figure / Table 제작

04 아웃라인에서 정한 제작 방식에 따라 Claude에게 요청합니다:

**matplotlib (수치 그래프):**

```
secondary/paper_comparison.md의 벤치마크 성능 데이터를 읽고
막대 그래프를 Python matplotlib으로 그려줘.
work_paper/figures/fig1.pdf로 저장해줘.
```

**TikZ (다이어그램):**

```
outline.md의 Figure 계획을 읽고 TikZ로 다이어그램을 그려줘.
main.tex의 해당 섹션에 \begin{tikzpicture}로 직접 넣어줘.
```

**Mermaid (흐름도):**

```
outline.md의 Figure 계획을 읽고 Mermaid 코드를 만들어줘.
mmdc -i fig1.mmd -o work_paper/figures/fig1.pdf로 변환해줘.
```

본문에 삽입:

```
main.tex의 해당 섹션에 Figure를 삽입해줘.
\includegraphics로 work_paper/figures/fig1.pdf를 참조하고,
캡션은 outline.md의 Figure 제목을 사용해줘.
```

Table은 비교표 변환에서 이미 만들어집니다 (위의 "비교표를 LaTeX 테이블로 변환" 참고).

### 인용 삽입

논문을 쓰면서 인용을 추가합니다:

```
Approaches 섹션에서 각 논문의 주요 수치를 인용할 때 적절한 \cite{}를 사용해줘.
수치는 반드시 primary/papers/의 원본 논문에서 가져와줘.
```

새로운 참고문헌이 필요하면:

```
이 논문도 인용하고 싶어: "Language Models are Few-Shot Learners" (Brown et al., 2020).
references.bib에 엔트리 추가하고 본문에서 인용해줘.
기존 키와 중복되지 않는지 확인하고.
```

### PDF 컴파일

```
work_paper/main.tex를 컴파일해서 PDF 만들어줘.
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

컴파일 에러가 나면:

```
컴파일 에러가 났어. main.log 읽고 고쳐줘.
```

| 에러 | 원인 | Claude에게 요청 |
|------|------|----------------|
| `Undefined control sequence` | 패키지 미설치 또는 오타 | "이 에러 고쳐줘" |
| `Citation undefined` | `.bib`에 키가 없음 | "references.bib에 빠진 엔트리 추가해줘" |
| `Missing $ inserted` | 수식 밖에서 `_` 사용 | "수식 기호 이스케이프 처리해줘" |


## 3. 검증

원고 초안이 완성되면 품질을 검증합니다.

### 인용 누락 체크

```
main.tex에서 사실적 주장(숫자, 성능, 비교)을 하면서 \cite{}가 없는 곳을 찾아줘.
```

### 비교표 vs 본문 일관성

```
secondary/paper_comparison.md의 수치와 main.tex 본문의 수치가 일치하는지 전수 검사해줘.
```

SSOT(비교표)와 본문에서 같은 수치를 다르게 쓰고 있지 않은지 확인합니다.

### BibTeX 정합성

```
references.bib의 모든 엔트리가 main.tex에서 인용되고 있는지,
반대로 main.tex의 모든 \cite{}가 references.bib에 있는지 교차 확인해줘.
```

### 최종 컴파일

```
최종 컴파일 한 번 더 해줘. warning 없이 깨끗하게 빌드되는지 확인하고,
warning이 있으면 알려줘.
```


## 실전 팁

### Hallucination 탐지 프롬프트 모음

```
# 사실 확인
"방금 쓴 Section 3에서 모든 수치의 출처를 논문명+페이지로 알려줘"

# 과장 표현 탐지
"본문에서 'significantly', 'dramatically', 'clearly superior' 같은
과장 표현을 찾아서, 데이터로 뒷받침되는지 확인해줘"

# 누락 확인
"secondary/outline.md와 비교해서, 본문에서 빠진 포인트가 있는지 확인해줘"
```

### 대규모 프로젝트로 확장할 때

| 규모 | 추가 사항 |
|------|----------|
| 10~30편 | `secondary/`에 분석표 SSOT 관리, 분석 파일 분리 |
| 30~100편 | 에이전트 팀으로 논문 분석 병렬화 ([에이전트 팀 문헌 수집](./03-collection.md) 참고) |
| 100편+ | 큐레이션 파이프라인 (에이전트 검증 → 사용자 선별), Supplementary Table 분리 |


## 체크리스트

- [ ] `primary/` 폴더는 수정되지 않았는가?
- [ ] 본문의 모든 수치가 `secondary/paper_comparison.md`와 일치하는가?
- [ ] 모든 `\cite{}`에 대응하는 `.bib` 엔트리가 있는가?
- [ ] 컴파일이 warning 없이 완료되는가?
- [ ] PDF에서 참고문헌 목록이 정상 출력되는가?


## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| pdflatex 미설치 | 섹션 1의 설치 명령어 실행 |
| 컴파일 시 패키지 에러 | `sudo tlmgr install <패키지명>` |
| 인용 번호가 `[?]`로 표시 | bibtex 실행 후 pdflatex 2회 재실행 |
| PDF 미리보기가 안 됨 | VS Code LaTeX Workshop 확장 설치 확인 |

---

> 💡 **Tip:** CLAUDE.md의 규칙은 구체적일수록 효과적입니다. "Be careful with citations"보다 "Every factual claim must have a `\cite{}`"가 Claude의 행동을 정확하게 제어합니다.

→ Part2-Research의 최종 단계입니다. 완성된 PDF를 `work_paper/`에서 확인하세요.
