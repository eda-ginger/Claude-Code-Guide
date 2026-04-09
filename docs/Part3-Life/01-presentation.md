# 발표 자료 생성

> 이 문서를 Claude에게 보여주면 Marp 기반 PDF 슬라이드를 생성합니다.

---

## 사전 요구사항

| 도구 | 용도 | 확인 방법 |
|------|------|-----------|
| Marp CLI | 마크다운 → PDF 변환 | `marp --version` |
| 한글 폰트 | PDF 한글 렌더링 | `fc-list :lang=ko` |
| NotebookLM CLI | 디자인 조언·슬라이드 생성 | `nlm --version` |

## 1. Marp CLI 설치

```bash
npm install -g @marp-team/marp-cli
```

한글 폰트가 없으면 PDF에서 글자가 깨집니다.

```bash
# Ubuntu/WSL
sudo apt install -y fonts-noto-cjk
```

## 2. 슬라이드 작성

`seminar/presentation.md` 파일을 마크다운으로 작성합니다. Marp 프론트매터로 테마와 스타일을 설정합니다.

```markdown
---
marp: true
theme: default
paginate: true
html: true
style: |
  section { font-family: 'Noto Sans KR', sans-serif; }
---

# 슬라이드 제목

내용 작성

---

# 다음 슬라이드
```

주요 Marp 문법:

| 문법 | 설명 |
|------|------|
| `---` | 슬라이드 구분 |
| `<!-- header: "텍스트" -->` | 빵크럼 네비게이션 |
| `<!-- _class: highlight -->` | 슬라이드별 CSS 클래스 |
| `![w:800](image.png)` | 이미지 삽입 (너비 지정) |
| `![bg left:40%](image.png)` | 배경 이미지 좌우 분할 |

## 3. PDF 변환

```bash
cd seminar
marp presentation.md --pdf --allow-local-files -o presentation.pdf
```

`--allow-local-files` 옵션은 로컬 이미지 참조 시 필요합니다.

## 4. 디자인 팁

- 인라인 `style=""` 속성은 Marp가 무시합니다. 반드시 `<style>` 블록에 CSS 클래스로 정의
- 슬라이드당 15줄 이하 권장 — 넘치면 내용이 잘림
- `<div class="grid grid-2">` 등 HTML + CSS 클래스로 다단 레이아웃 구성
- `.card`, `.badge`, `.accent` 등 재사용 가능한 CSS 컴포넌트를 프론트매터에 미리 정의

## 5. NotebookLM 활용

NLM PPT 가이드 노트북에 슬라이드 파일을 업로드하고 디자인 평가를 받을 수 있습니다.

```bash
# 소스 추가
nlm source add <notebook-id> --file presentation.md

# 디자인 평가 요청
nlm notebook query <notebook-id> "이 슬라이드의 디자인을 평가해줘"

# NLM 자체 슬라이드 생성
# 노트북 스튜디오 탭에서 슬라이드 생성 가능
nlm studio status <notebook-id>
```

## 트러블슈팅

| 증상 | 해결 |
|------|------|
| PDF에서 한글 깨짐 | `sudo apt install fonts-noto-cjk` 후 재빌드 |
| 이미지 안 보임 | `--allow-local-files` 옵션 추가 |
| CSS 적용 안 됨 | 인라인 style 대신 `<style>` 블록에 클래스 정의 |
| 슬라이드 내용 잘림 | 텍스트 줄이기 또는 폰트 크기 축소 |

---

> 💡 **Tip:** Marp PDF는 빠르게 만들기 좋지만, 디자인에 한계가 있습니다. 더 나은 디자인이 필요하면 NotebookLM의 슬라이드 생성 기능이나 python-pptx 템플릿 기반 접근을 고려하세요.
