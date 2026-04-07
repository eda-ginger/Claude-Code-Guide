# k-skill — 한국 생활 밀착형 AI 스킬 모음

> Claude Code에서 한국 생활 서비스를 바로 사용할 수 있는 25개 이상의 스킬 패키지

---

## 개요

[k-skill](https://github.com/NomaDamas/k-skill)은 한국 사용자를 위한 AI 에이전트 스킬 모음입니다. Claude Code, Codex, OpenCode 등 코딩 에이전트에서 사용할 수 있으며, 교통, 쇼핑, 금융, 스포츠, 생활 정보 등 다양한 한국 서비스를 자연어로 제어할 수 있습니다.

---

## 설치

> 자세한 설치 방법은 [공식 설치 가이드](https://github.com/NomaDamas/k-skill/blob/main/docs/install.md)를 참고하세요.

### 1단계: 스킬 설치

```bash
npx --yes skills add NomaDamas/k-skill --all -g
```

### 2단계: 의존성 설치

```bash
# Node.js 의존성
npm install -g @ohah/hwpjs kbo-game kleague-results lck-analytics \
  toss-securities k-lotto coupang-product-search used-car-price-search \
  cheap-gas-nearby korean-law-mcp daiso

export NODE_PATH="$(npm root -g)"

# Python 의존성 (SRT/KTX 예매용)
python3 -m pip install SRTrain korail2 pycryptodome
```

### 3단계: 셋업 유틸리티 실행

설치 후 Claude Code에서 아래와 같이 요청하면 인증 정보(credential)와 환경 변수를 자동으로 설정합니다:

```
k-skill-setup 스킬을 사용해서 공통 설정을 진행해줘
```

---

## 스킬 카테고리

### 교통/여행

| 스킬 | 설명 | 인증 필요 |
|------|------|:---------:|
| SRT 예매 | SRT 열차 조회 및 예매 | O |
| KTX 예매 | KTX 열차 조회 및 예매 | O |
| 서울 지하철 | 실시간 도착 정보 조회 | X |
| 택배 조회 | 배송 상태 추적 | X |

### 쇼핑/생활

| 스킬 | 설명 | 인증 필요 |
|------|------|:---------:|
| 쿠팡 상품 검색 | 쿠팡 상품 조회 및 비교 | X |
| 다이소 재고 조회 | 매장별 재고 확인 | X |
| 올리브영 재고 조회 | 매장별 재고 확인 | X |
| 중고차 시세 | 중고차 가격 조회 | X |

### 금융

| 스킬 | 설명 | 인증 필요 |
|------|------|:---------:|
| 토스증권 | 포트폴리오 조회 | O |

### 스포츠/엔터

| 스킬 | 설명 | 인증 필요 |
|------|------|:---------:|
| KBO 야구 | 경기 결과 및 순위 | X |
| K리그 | 축구 순위 및 결과 | X |
| LCK e스포츠 | 리그 분석 및 결과 | X |
| 로또 당첨 확인 | 회차별 당첨 번호 조회 | X |

### 정보/공공서비스

| 스킬 | 설명 | 인증 필요 |
|------|------|:---------:|
| 미세먼지 | 지역별 대기질 조회 | X |
| 한강 수위 | 실시간 한강 수위 | X |
| 부동산 실거래가 | 아파트/주택 거래 내역 | API 키 |
| 법령 검색 | 한국 법률/법령 조회 | X (로컬은 API 키) |
| 조선왕조실록 | 조선왕조실록 검색 | X |
| 최저가 주유소 | 주변 주유소 가격 비교 | API 키 |
| 우편번호 조회 | 주소별 우편번호 검색 | X |

### 유틸리티

| 스킬 | 설명 | 인증 필요 |
|------|------|:---------:|
| 카카오톡 macOS CLI | 카카오톡 메시지 전송 | O |
| HWP 변환 | 한글 문서 변환/처리 | X |
| 맞춤법 검사 | 한국어 맞춤법 교정 | X |
| 주변 맛집 | 근처 음식점 검색 | X |

---

## 사용 예시

설치 후 Claude Code에서 자연어로 바로 사용할 수 있습니다:

```
서울역에서 부산까지 SRT 열차 조회해줘

오늘 KBO 경기 결과 알려줘

강남역 근처 미세먼지 어때?

이 택배 어디쯤 왔는지 확인해줘 (운송장번호: 1234567890)

이번주 로또 당첨번호 알려줘

"안녕하세여"를 맞춤법 검사해줘
```

---

## 인증 설정

대부분의 스킬은 인증 없이 바로 사용 가능합니다. 인증이 필요한 스킬은 `k-skill-setup`을 통해 설정합니다:

- **SRT/KTX**: 각 서비스 계정 정보
- **토스증권**: 토스 인증 정보
- **카카오톡**: macOS 카카오톡 앱 연동
- **부동산/주유소**: 공공데이터포털 API 키 (`DATA_GO_KR_API_KEY`, `OPINET_API_KEY`)

---

## 참고 링크

- GitHub: [NomaDamas/k-skill](https://github.com/NomaDamas/k-skill)
- 설치 가이드: [docs/install.md](https://github.com/NomaDamas/k-skill/blob/main/docs/install.md)
- 보안 정책: [docs/security.md](https://github.com/NomaDamas/k-skill/blob/main/docs/security.md)
