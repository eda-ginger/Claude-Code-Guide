# k-skill — 한국 생활 밀착형 AI 스킬 모음

> 이 문서를 Claude에게 보여주면 한국 생활 서비스 25개 이상의 스킬을 설치하고 바로 사용할 수 있습니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Claude Code | 스킬 실행 환경 | `claude --version` |
| Node.js 18+ | 스킬 패키지 실행 | `node --version` |
| Python 3.10+ | SRT/KTX 예매 (선택) | `python3 --version` |

## 1. k-skill이란?

[k-skill](https://github.com/NomaDamas/k-skill)은 한국 사용자를 위한 AI 에이전트 스킬 모음입니다. Claude Code에서 교통, 쇼핑, 금융, 스포츠, 생활 정보 등 다양한 한국 서비스를 자연어로 제어할 수 있습니다.

## 2. 설치

> 자세한 설치 방법은 [공식 설치 가이드](https://github.com/NomaDamas/k-skill/blob/main/docs/install.md)를 참고하세요.

### 스킬 설치

```bash
npx --yes skills add NomaDamas/k-skill --all -g
```

26개 스킬이 `~/.agents/skills/`에 설치되며, Claude Code에 자동으로 symlink 됩니다.

### 의존성 설치

```bash
# Node.js 의존성
npm install -g @ohah/hwpjs kbo-game kleague-results lck-analytics \
  toss-securities k-lotto used-car-price-search \
  cheap-gas-nearby korean-law-mcp daiso

# Python 의존성 (SRT/KTX 예매용)
python3 -m pip install SRTrain korail2 pycryptodome
```

### NODE_PATH 영구 설정

```bash
echo 'export NODE_PATH="$(npm root -g)"' >> ~/.bashrc
source ~/.bashrc
```

### 설치 확인

```bash
ls ~/.claude/skills/ | grep -c .   # Claude Code에 연결된 스킬 수
node -e "require('@ohah/hwpjs'); console.log('hwpjs OK')"
python3 -c "import SRTrain; print('SRTrain OK')"
```

### 셋업 유틸리티 (선택)

인증이 필요한 스킬(SRT, KTX, 토스증권 등)을 사용하려면 Claude Code에서:

```
k-skill-setup 스킬을 사용해서 공통 설정을 진행해줘
```

> 인증 없이 사용 가능한 스킬이 대부분이므로, 먼저 인증 불필요 스킬부터 사용해볼 수 있습니다.

## 3. 스킬 카테고리 및 동작 상태

> **상태 범례**: ✅ 테스트 완료 · 🔑 인증/API 키 필요 · 🚫 현재 미지원

### ✅ 설치 후 바로 사용 가능

| 스킬 | 설명 | 비고 |
|------|------|------|
| 로또 당첨 확인 | 회차별 당첨 번호 조회 | `k-lotto` npm 패키지 |
| KBO 야구 | 경기 결과 및 순위 | `kbo-game` npm 패키지 |
| K리그 | 축구 순위 및 결과 | `kleague-results` npm 패키지 |
| LCK e스포츠 | 리그 분석 및 결과 | `lck-analytics` npm 패키지 |
| 미세먼지 | 지역별 대기질 조회 | k-skill-proxy 경유 |
| 한강 수위 | 실시간 수위/유량 | k-skill-proxy 경유 |
| 서울 지하철 | 실시간 도착 정보 | k-skill-proxy 경유 |
| 맞춤법 검사 | 한국어 맞춤법 교정 | 스킬 내장 Python 스크립트 |
| 조선왕조실록 | 실록 검색 + 국역/원문 | 스킬 내장 Python 스크립트 |
| 우편번호 조회 | 주소별 우편번호 검색 | 우체국 공식 검색 |
| 중고차 시세 | SK렌터카 인수가/월렌트 조회 | 공개 inventory snapshot |
| 택배 조회 | CJ대한통운/우체국 배송 추적 | 송장번호 필요 |

### 🔑 인증 또는 API 키 필요

| 스킬 | 설명 | 필요 조건 |
|------|------|-----------|
| SRT 예매 | SRT 열차 조회/예매 | SRT 계정 |
| KTX 예매 | KTX 열차 조회/예매 | 코레일 계정 (anti-bot 차단 가능) |
| 토스증권 | 포트폴리오/시세 조회 | macOS + `tossctl` 로그인 |
| 카카오톡 macOS CLI | 메시지 전송 | macOS + 카카오톡 앱 |
| 부동산 실거래가 | 아파트/주택 거래 내역 | `DATA_GO_KR_API_KEY` |
| 최저가 주유소 | 주변 주유소 가격 비교 | `OPINET_API_KEY` |
| 법령 검색 | 한국 법률/법령 조회 | `LAW_OC` API 키 |

### 🚫 현재 미지원

| 스킬 | 사유 |
|------|------|
| 다이소/올리브영 재고 | npm 패키지 미출시 |
| 주변 맛집/술집 | 프록시 세션 키 미설정 |
| 쿠팡 상품 검색 | MCP API 호출 제한 |
| HWP 변환 | 테스트 미완 |

## 4. 사용 예시

설치 후 Claude Code에서 자연어로 바로 사용할 수 있습니다.

| 질문 방식 | 예상 결과 |
|-----------|-----------|
| `이번주 로또 당첨번호 알려줘` | 최신 회차 번호 + 당첨금 |
| `어제 KBO 경기 결과 알려줘` | 전 경기 스코어 테이블 |
| `종로구 미세먼지 알려줘` | PM10/PM2.5 수치 + 등급 |
| `강남역 지하철 도착 정보` | 호선별 도착 예정 시간 |
| `한강대교 수위 알려줘` | 현재 수위(m) + 유량 |
| `"안녕하세여" 맞춤법 검사해줘` | 교정 결과 + 이유 |
| `이순신 조선왕조실록 검색해줘` | 왕별 분류 + 국역/원문 |
| `테헤란로 152 우편번호` | 우편번호 + 주소 |
| `아반떼 중고차 시세` | 인수가 + 연식/주행거리 |
| `CJ대한통운 송장 1234567890 조회` | 배송 상태 + 이벤트 이력 |
| `LCK 최근 경기 결과` | 세트 스코어 + 순위 |
| `K리그 경기 결과` | 스코어 + 현재 순위 |

## 5. 인증 설정

대부분의 스킬은 인증 없이 바로 사용 가능합니다. 인증이 필요한 스킬은 `k-skill-setup`을 통해 설정합니다:

- **SRT/KTX**: 각 서비스 계정 정보
- **토스증권**: 토스 인증 정보
- **부동산/주유소**: 공공데이터포털 API 키

## 트러블슈팅

| 문제 | 해결 방법 |
|------|-----------|
| `npm error 404` | 패키지명 변경 가능. [공식 가이드](https://github.com/NomaDamas/k-skill/blob/main/docs/install.md) 확인 |
| 스킬이 Claude Code에서 안 보임 | `~/.claude/skills/` symlink 확인. `npx skills add` 재실행 |
| `NODE_PATH` 에러 | `echo $NODE_PATH`로 확인. 비어있으면 설정 재실행 |
| Python import 에러 | `python3 -m pip install --upgrade SRTrain korail2 pycryptodome` |
| 미세먼지 조회 실패 | k-skill-proxy 상태 확인. 일부 시간대 측정값 없음 |
| SRT/KTX MACRO ERROR | 코레일 anti-bot 차단. 시간 간격 두고 재시도 |

---

> 💡 **Tip:** 인증 없이 바로 쓸 수 있는 12개 스킬부터 시작하세요. 로또, KBO, 미세먼지, 지하철 도착 등 일상에서 자주 쓰는 것부터 익숙해지면 인증 스킬까지 확장할 수 있습니다.
