# 에이전트 팀 문헌 자동 수집

> Agent Teams + 학술 API + NotebookLM + Playwright를 조합하여 체계적 문헌 수집을 자동화하는 튜토리얼
>
> **예제 주제**: Drug-Drug Interaction(DDI) 예측 논문 수집 (2018~2026)

---

## 이런 상황에서 사용합니다

- 특정 주제의 논문을 **빠짐없이** 수집해야 할 때
- 여러 학술 DB를 동시에 검색하고 싶을 때
- 수백 편의 PDF를 자동으로 다운로드하고 싶을 때
- 수작업 문헌 검색에 며칠이 걸리는 게 싫을 때

이 프로세스를 사용하면 **1~2시간** 안에 5개 검색 엔진을 병렬로 돌려 논문을 수집하고, PDF까지 자동으로 확보할 수 있습니다.

---

## 전체 프로세스 개요

```
Phase 1: 팀 설계                Phase 2: 병렬 수집              Phase 3: 병합·검증
┌──────────────────┐    ┌──────────────────────────┐    ┌─────────────────┐
│ 포함/제외 기준 정의 │    │         Leader           │    │ 중복 제거        │
│ 검색 쿼리 설계     │ →  │  ┌─A─┐ ┌─B─┐ ┌─C─┐     │ →  │ 스코프 필터      │
│ 에이전트 역할 배분  │    │  │Pub│ │S2 │ │DBLP│     │    │ 교차 검증        │
│                  │    │  └───┘ └───┘ └───┘     │    │ 최종 리스트 확정  │
│                  │    │  ┌─D─┐ ┌─E─┐           │    │                 │
│                  │    │  │NLM│ │Cite│           │    │                 │
│                  │    │  └───┘ └───┘           │    │                 │
└──────────────────┘    └──────────────────────────┘    └─────────────────┘

Phase 4: PDF 수집
┌──────────────────────────────┐
│ API로 PDF URL 확보            │
│ → Playwright 자동 다운로드     │
│ → 실패분 수동 보완             │
└──────────────────────────────┘
```

---

## 사전 준비

### 필수 도구

| 도구 | 용도 | 설치 확인 |
|------|------|----------|
| Claude Code | Agent Teams 실행 | `claude --version` |
| tmux | 팀원 모니터링 | `tmux -V` |
| nlm (NotebookLM CLI) | Deep Research | `nlm login --check` |
| Node.js | Playwright 실행 | `node --version` |

### API 키 준비

| API | 용도 | 신청 방법 |
|-----|------|----------|
| Semantic Scholar | 논문 검색 + 인용 추적 | [semanticscholar.org/product/api](https://www.semanticscholar.org/product/api) 에서 신청 |
| PubMed E-utilities | 생의학 논문 검색 | API 키 불필요 (email 파라미터 권장) |
| DBLP | CS 학회 논문 검색 | API 키 불필요 |
| Unpaywall | OA PDF URL 조회 | API 키 불필요 (email 파라미터 필수) |

### Playwright 설치 (PDF 다운로드용)

```bash
npm install playwright playwright-extra puppeteer-extra-plugin-stealth
npx playwright install chromium

# Linux 서버의 경우 시스템 라이브러리도 필요
sudo apt-get install -y libnspr4 libnss3 libatk1.0-0 libatk-bridge2.0-0 \
  libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 \
  libgbm1 libpango-1.0-0 libcairo2 libasound2
```

---

## Phase 1: 팀 설계

논문 수집을 시작하기 전에, **무엇을 찾을 것인지**와 **누가 어디서 찾을 것인지**를 정의합니다.

### 1-1. 포함/제외 기준 정의

자기 주제에 맞게 기준을 먼저 작성합니다. 예시:

```markdown
## Inclusion / Exclusion Criteria

### 포함 (Include)
- Drug-Drug Interaction prediction (binary / multi-class / multi-label)
- Drug-Drug Interaction extraction from text (NER, RE)
- 연도: 2018 ~ 2026
- 언어: 영어 논문만
- peer-reviewed + arXiv preprint 모두 포함

### 제외 (Exclude)
- Drug-supplement / Herb-drug interaction
- DDI가 아닌 일반 link prediction
- Clinical cohort study (no computational benchmark)
- 리뷰/서베이 논문 → 별도 리스트로 분리
```

> **팁**: 제외 기준을 명확히 적어두면 에이전트가 자동 필터링할 때 정확도가 올라갑니다.

### 1-2. 에이전트 팀 구조 설계

검색 엔진별로 에이전트를 배치합니다. 5명 구성이 범용적으로 잘 작동합니다:

```
                    ┌─ [Teammate A: PubMed]          → 생의학 저널
                    ├─ [Teammate B: Semantic Scholar] → CS+Bio 교차 영역
[Leader/Conductor] ─┼─ [Teammate C: DBLP + arXiv]    → CS 학회 + preprint
                    ├─ [Teammate D: NotebookLM]      → Deep Research (놓친 논문 발견)
                    └─ [Teammate E: Google Scholar]   → 웹 검색 기반 보완
```

| 에이전트 | 검색 엔진 | 강점 |
|---------|----------|------|
| A | PubMed (E-utilities API) | 생의학 저널 커버리지 최고 |
| B | Semantic Scholar API | CS+Bio 교차, DOI/arXiv ID 자동 제공 |
| C | DBLP + arXiv API | 학회 논문 + preprint |
| D | NotebookLM (nlm CLI) | Google 검색 기반, 다른 엔진이 놓친 논문 발견 |
| E | Google Scholar (WebSearch) | 웹 검색 기반, 다른 API가 놓친 논문 보완 |

> **자기 분야에 맞게 조정**: 예를 들어 사회과학이면 PubMed 대신 Web of Science, CS 위주면 DBLP 비중을 높이는 식으로.

### 1-3. 검색 쿼리 설계

에이전트별로 사용할 검색 쿼리를 미리 작성합니다:

```markdown
## 검색 쿼리

### PubMed
- "drug-drug interaction" AND ("prediction" OR "extraction")
- "DDI" AND ("deep learning" OR "machine learning")
- MeSH: "Drug Interactions"[MeSH] AND "Deep Learning"[MeSH]

### Semantic Scholar
- drug-drug interaction prediction
- DDI prediction graph neural network
- DDI prediction knowledge graph
- drug-drug interaction extraction NLP

### DBLP + arXiv
- drug-drug interaction prediction (DBLP)
- cs.AI, cs.LG, q-bio.QM 카테고리 (arXiv)

### NotebookLM Deep Research (5개 쿼리)
- "Computational methods for DDI prediction using molecular structure..."
- "DDI prediction using knowledge graphs..."
- "DDI prediction using NLP, LLM..."
- "DDI extraction from biomedical text..."
- "Multi-modal DDI prediction..."

### Google Scholar
- site:scholar.google.com "drug-drug interaction prediction"
- "DDI" "deep learning" "benchmark" 등 다양한 키워드 조합
- 다른 API에서 놓친 논문을 웹 검색으로 보완
```

---

## Phase 2: 병렬 수집 실행

### 2-1. 팀 생성 프롬프트

tmux 세션에서 Claude Code를 실행하고, 아래 프롬프트를 리더에게 전달합니다:

```
논문 수집 팀을 만들어줘. 5명의 팀원이 각각 다른 검색 엔진을 담당해:

- Teammate A (pubmed): PubMed에서 [내 주제] 논문 검색. E-utilities API 활용.
- Teammate B (semantic): Semantic Scholar API로 [내 주제] 검색. 키워드별 페이지네이션.
- Teammate C (dblp): DBLP API + arXiv에서 학회 논문과 preprint 검색.
- Teammate D (nlm): NotebookLM CLI(nlm)로 Deep Research 5회 실행.
- Teammate E (scholar): Google Scholar WebSearch로 다른 엔진이 놓친 논문 보완 검색.

각 팀원은 결과를 [출력 폴더] 에 자기 파일로 저장해.
모두 완료되면 나(리더)에게 알려줘. 내가 병합하고 중복 제거할게.
각 팀원은 Sonnet 모델을 사용해.
```

### 2-2. 각 에이전트의 작동 방식

**Teammate A — PubMed:**
```bash
# E-utilities API로 검색
# esearch → efetch, retmax=100씩 페이지네이션
# 연도 필터 적용
```

**Teammate B — Semantic Scholar:**
```bash
# /graph/v1/paper/search 엔드포인트
# API key 헤더: x-api-key
# offset 기반 페이지네이션, 요청 간 1.5초 간격
# fields: title, authors, year, venue, externalIds, abstract
```

**Teammate C — DBLP + arXiv:**
```bash
# DBLP: /search/publ/api?q=...&format=json&h=100&f=0
# arXiv: https://export.arxiv.org/api/query (반드시 HTTPS)
# 페이지네이션으로 전체 결과 수집
```

**Teammate D — NotebookLM:**
```bash
# 노트북 생성
nlm notebook create "내 연구 주제 Paper Collection"

# Deep Research 실행 (쿼리별)
nlm research start "쿼리 1" --notebook-id <id> --mode deep
nlm research start "쿼리 2" --notebook-id <id> --mode deep
# ... 각 ~5분, 순차 실행

# 결과 임포트 + 리포트 생성
nlm research status <id>
nlm research import <id> <task-id>
nlm report create <id> --format "Create Your Own" \
  --prompt "모든 소스에서 언급된 개별 논문을 마크다운 테이블로 나열해줘" \
  --confirm
```

**Teammate E — Google Scholar:**
```bash
# WebSearch 도구로 Google Scholar 검색
# 다양한 키워드 조합으로 다른 API가 놓친 논문 발견
# 예: "drug-drug interaction prediction" site:scholar.google.com
#     "DDI" "graph neural network" "benchmark"
# 검색 결과에서 제목, 저자, 연도, venue 추출
```

### 2-3. 팀원 간 소통

팀원들은 독립적으로 검색하지만, 리더를 통한 소통으로 수집 품질을 높일 수 있습니다.

#### 소통 방식

Agent Teams에서는 **SendMessage**로 팀원↔리더 간 메시지를 주고받고, **공유 Tasks**로 진행 상황을 추적합니다. 모든 소통은 리더를 허브로 거치는 구조입니다.

#### 유용한 소통 시나리오

**1. 효과적인 키워드 공유**

```
Teammate A ──"PubMed에서 'multi-modal DDI' 키워드로 30편 추가 발견"
    ──► Leader ──"이 키워드로도 검색해봐"──► Teammate E (Google Scholar)
```

한 에이전트에서 잘 먹힌 키워드를 다른 에이전트에게 공유하면 커버리지가 넓어집니다.

**2. 노이즈 필터 조정**

```
Teammate B ──"500편 나왔는데 DDI와 무관한 drug repositioning 논문이 많아"
    ──► Leader ──"제외 기준에 drug repositioning 추가. 필터 좁혀서 재검색해"
    ──► Teammate B (필터 강화)
```

검색 중 노이즈가 많으면 리더가 포함/제외 기준을 실시간으로 보완합니다.

**3. 새로운 하위 분야 발견**

```
Teammate D ──"NLM에서 'contrastive learning for DDI'라는 새 접근법 발견"
    ──► Leader ──"이 키워드 추가 검색 요청"──► Teammate A, B, C
```

NotebookLM Deep Research에서 예상 못 한 하위 분야가 나오면 다른 에이전트들에게 추가 쿼리를 요청합니다.

**4. 진행 상황 보고**

```
Teammate A ──"PubMed 완료: 87편"──►
Teammate B ──"S2 완료: 203편"────►
Teammate C ──"DBLP 완료: 52편"──► Leader ──"전원 완료 확인. Phase 3 병합 시작할게"
Teammate D ──"NLM 완료: 65편"───►
Teammate E ──"Scholar 완료: 43편"►
```

각 팀원이 완료를 보고하면, 리더가 전원 완료를 확인하고 Phase 3(병합)으로 넘어갑니다.

#### 소통 팁

- **리더를 통한 조율** 권장 — 팀원 간 직접 메시지도 가능하지만, 리더가 전체 그림을 보고 판단하는 게 효율적
- **tmux 분할 창**으로 모든 팀원의 작업을 실시간 모니터링
- 소통이 과하면 오히려 작업이 느려지므로, **큰 발견이 있을 때만** 보고하도록 팀 생성 시 지시

### 2-4. 산출물 형식

각 팀원이 동일한 형식으로 결과를 저장합니다:

```markdown
| Title | Authors | Year | Venue | DOI | arXiv ID | Status | Notes |
|-------|---------|------|-------|-----|----------|--------|-------|
| SumGNN | ... | 2021 | KDD | 10.1145/... | - | published | |
| ... | ... | ... | ... | ... | ... | ... | ... |
```

---

## Phase 3: 병합 및 검증

리더(또는 사용자)가 5개 팀원의 결과를 취합합니다.

### 3-1. 중복 제거

```
1. DOI 기준 exact match
2. DOI 없는 경우: 제목 유사도 (fuzzy match, 90%+)
3. 동일 논문이 여러 에이전트에서 발견 → Source에 모두 기재 (예: "A,B,D")
```

### 3-2. arXiv → 저널 통일

arXiv preprint이 이후 저널에 게재된 경우, 저널 버전으로 통일합니다:

```
Semantic Scholar API로 arXiv paper의 DOI 존재 여부 일괄 확인
→ 저널 게재 확인 시 저널 버전으로 교체
→ 미게재 preprint은 arXiv 버전 유지
```

### 3-3. 스코프 필터링

Phase 1에서 정의한 포함/제외 기준을 적용합니다:

```
- Abstract 기반으로 해당 여부 판단
- 경계 케이스는 [?] 플래그 → 사용자 최종 판단
- 서베이 논문은 별도 리스트로 분리
```

### 3-4. 최종 리스트

```markdown
| # | Title | Authors | Year | Venue | DOI | arXiv ID | Status | Source | PDF |
|---|-------|---------|------|-------|-----|----------|--------|--------|-----|
| 1 | ... | ... | 2018 | ... | 10.xxx | - | published | A,D | No |
| 2 | ... | ... | 2019 | ... | - | 2019.xxxxx | preprint | C | No |
```

---

## Phase 4: PDF 자동 수집

### 4-1. PDF URL 확보

Unpaywall API + Semantic Scholar API로 각 논문의 PDF URL을 조회합니다:

```bash
# Unpaywall: DOI로 OA PDF URL 조회
curl -s "https://api.unpaywall.org/v2/${DOI}?email=내메일@example.com"
# → best_oa_location.url_for_pdf

# Semantic Scholar: openAccessPdf 필드 확인
# → /paper/{id}?fields=openAccessPdf
```

PDF 소스 우선순위:

| 순위 | 소스 | 방법 |
|-----|------|------|
| 1 | arXiv | `https://arxiv.org/pdf/{id}.pdf` |
| 2 | Semantic Scholar | `openAccessPdf` 필드 |
| 3 | DOI → Publisher | OA 저널 (MDPI, Frontiers, PMC 등) |
| 4 | PubMed Central | PMCID로 다운로드 |
| 5 | 수동 | 대학 VPN 등으로 직접 |

### 4-2. Playwright 자동 다운로드

확보한 URL을 Playwright + Stealth 플러그인으로 자동 다운로드합니다:

```javascript
const { chromium } = require('playwright-extra');
const stealth = require('puppeteer-extra-plugin-stealth')();
chromium.use(stealth);

async function downloadPDF(context, url, outPath) {
  const page = await context.newPage();
  try {
    const [download] = await Promise.all([
      page.waitForEvent('download', { timeout: 30000 }).catch(() => null),
      page.goto(url, { timeout: 30000 }).catch(() => {})
    ]);
    if (download) {
      await download.saveAs(outPath);
      // PDF 검증: 매직바이트 확인
      const buf = require('fs').readFileSync(outPath);
      return buf.slice(0, 5).toString().startsWith('%PDF');
    }
    return false;
  } finally {
    await page.close();
  }
}

// 전체 논문 순회
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ acceptDownloads: true });

for (const paper of paperList) {
  const ok = await downloadPDF(context, paper.pdfUrl, paper.outPath);
  paper.pdfAcquired = ok ? 'Yes' : 'No';
  await new Promise(r => setTimeout(r, 3000)); // rate limit
}
```

**핵심 포인트:**
- `playwright-extra` + `stealth` 플러그인으로 봇 감지 우회
- `download` 이벤트 방식으로 Publisher별 차이 없이 통일 처리
- 요청 간 3초 간격으로 rate limit 준수
- `%PDF-` 매직바이트로 실제 PDF인지 자동 검증

### 4-3. 실패분 수동 보완

자동 다운로드가 실패하는 경우:

| 실패 사유 | 해결 방법 |
|----------|----------|
| Cloudflare CAPTCHA | 브라우저에서 직접 다운로드 |
| 유료 저널 | 대학 VPN으로 접근 |
| DOI/URL 없음 | Google Scholar에서 검색 |

실패 로그를 남겨서 수동 보완을 쉽게 합니다:

```markdown
## 다운로드 실패 목록

| # | Title | Year | DOI Link | 실패 사유 | 대안 |
|---|-------|------|----------|----------|------|
| 12 | KGNN | 2020 | [DOI](https://doi.org/...) | CAPTCHA | PMC 검색 |
| 25 | NP-KG | 2023 | [DOI](https://doi.org/...) | 유료 | 대학 VPN |
```

### 4-4. 파일 저장 구조

```
papers/
├── 001_ModelName_2018.pdf
├── 002_ModelName_2019.pdf
├── ...
└── 331_ModelName_2026.pdf
```

파일명 규칙: `{###}_{모델명}_{연도}.pdf` (리스트의 번호와 일치)

---

## 실전 결과 예시: DDI 논문 수집

이 프로세스를 DDI(Drug-Drug Interaction) 예측 논문 수집에 적용한 결과:

### 수집 성과

| 에이전트 | 검색 결과 수 |
|---------|------------|
| A (PubMed) | 1,593건 |
| B (Semantic Scholar) | 5,637건 |
| C (DBLP + arXiv) | 879건 |
| D (NotebookLM) | Deep Research 5쿼리 |
| E (Citation) | 시드 20편 기반 |

→ 중복 제거 + 스코프 필터 후 **최종 331편** 확정
→ 서베이 논문 48편 별도 분리

### PDF 확보율

| 단계 | 편수 | 비율 |
|------|------|------|
| Playwright 자동 | 121편 | 36.6% |
| 수동 보완 | 113편 | 34.1% |
| 확보 불가 (제외) | 47편 | 14.2% |
| 분석 불필요 | 50편 | 15.1% |
| **유효 PDF** | **234편** | **70.7%** |

### 소요 시간

| 단계 | 시간 |
|------|------|
| Phase 2: 병렬 수집 | ~1.5시간 |
| Phase 3: 병합·검증 | ~1시간 |
| Phase 4: PDF 자동 다운로드 | ~2시간 |
| Phase 4: 수동 보완 | ~3시간 |
| **합계** | **~7.5시간** |

> 수작업으로 동일 규모를 수집하면 2~3일이 걸리는 작업을 하루 안에 완료했습니다.

---

## 자기 주제에 적용하기

### 체크리스트

1. **포함/제외 기준** 작성 — 무엇을 찾고 무엇을 제외할지
2. **검색 쿼리** 설계 — 에이전트별 키워드와 필터
3. **API 키** 준비 — Semantic Scholar 키 신청 (~1~2일)
4. **Google Scholar 키워드** 준비 — 다른 API 보완용 다양한 키워드 조합
5. **NotebookLM 쿼리** 작성 — 주제의 하위 분야별 5개 쿼리
6. **팀 생성 프롬프트** 커스터마이징 — 자기 주제에 맞게 수정

### 에이전트 수 조정

모든 주제에 5명이 필요한 것은 아닙니다:

| 분야 | 추천 구성 |
|------|----------|
| 생의학 | A(PubMed) + B(S2) + D(NLM) + E(Scholar) |
| CS/AI | B(S2) + C(DBLP) + D(NLM) + E(Scholar) |
| 융합 분야 | 5명 전원 (검색 엔진 커버리지 최대화) |
| 소규모 탐색 | B(S2) + D(NLM) 2명만으로도 충분 |

---

## 주의사항

### 저작권
- Open Access 또는 저자 공개 버전만 수집
- 대학 라이선스 범위 내에서 다운로드
- PDF는 git에 올리지 않기 (`.gitignore`에 추가)

### API Rate Limit
- Semantic Scholar: API 키 있으면 1 RPS, 없으면 제한적
- PubMed: 초당 3건 (API 키 없이)
- Playwright: 요청 간 3초 이상 간격 유지

### 팁
- NotebookLM Deep Research는 **다른 엔진이 놓친 논문**을 잡는 데 특히 유용
- Google Scholar는 **API가 커버하지 못하는 영역**(학위논문, 비주류 저널 등)을 보완
- 리더를 통한 조율로 에이전트 간 발견 사항을 실시간 공유하면 수집 품질 향상

---

## 참고 자료

- [tmux와 에이전트 팀](./03_Tmux_and_Agent_Teams.md) — Agent Teams 기본 사용법
- [NotebookLM CLI 연동](./06_NotebookLM_CLI.md) — nlm CLI 설치 및 활용
- [Semantic Scholar API 문서](https://api.semanticscholar.org/)
- [PubMed E-utilities](https://www.ncbi.nlm.nih.gov/books/NBK25501/)
- [Unpaywall API](https://unpaywall.org/products/api)
- [Playwright 공식 문서](https://playwright.dev/)
