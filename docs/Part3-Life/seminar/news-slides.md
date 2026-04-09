---
marp: true
theme: default
paginate: false
html: true
style: |
  @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700;900&display=swap');

  section {
    font-family: 'Noto Sans KR', sans-serif;
    font-size: 22px;
    padding: 40px 60px;
    color: #1e293b;
    background: #ffffff;
  }

  /* 신문 스타일 */
  .paper-header {
    border-bottom: 3px solid #0f172a;
    padding-bottom: 8px;
    margin-bottom: 16px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 0.65em;
    color: #64748b;
  }
  .paper-name { font-size: 1.2em; font-weight: 900; color: #0f172a; letter-spacing: 2px; }

  .headline { font-size: 1.6em; font-weight: 900; color: #0f172a; line-height: 1.3; margin: 8px 0; }
  .subhead { font-size: 0.95em; color: #475569; margin-bottom: 16px; }

  .article-body { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
  .article-img { border-radius: 6px; border: 1px solid #e2e8f0; }

  .key-figure {
    background: #f1f5f9;
    border-left: 4px solid #2563eb;
    padding: 12px 16px;
    border-radius: 0 8px 8px 0;
    margin: 8px 0;
    font-size: 0.85em;
  }
  .key-figure strong { color: #2563eb; font-size: 1.3em; }

  .caption { font-size: 0.6em; color: #94a3b8; margin-top: 4px; }
  .red { color: #e94560; }
---

<div class="paper-header">
<span class="paper-name">AI WEEKLY</span>
<span>2026.04.07</span>
</div>

<div class="headline">Anthropic, 매출 $30B 돌파하며 OpenAI 첫 추월</div>
<div class="subhead">Google·Broadcom과 3.5GW 규모 차세대 TPU 장기 공급 계약 체결</div>

<div class="article-body">
<div>

<div class="key-figure">
연매출 런레이트 <strong>$30B</strong> (OpenAI $25B 역전)
<br>15개월 만에 $1B → $30B · 성장률 10배/년
</div>

<div class="key-figure">
TPU 컴퓨팅 <strong>3.5GW</strong>
<br>2027년부터 Broadcom 공급, 2031년까지 계약
</div>

<div class="key-figure">
Broadcom (칩 제조) → Google (클라우드 제공) → Anthropic (Claude 운영)
</div>

</div>
<div>

![w:500](Fig/electric.png)

<div class="caption">출처: TechCrunch, Bloomberg · 2026.04.07</div>

</div>
</div>

---

<div class="paper-header">
<span class="paper-name">AI WEEKLY</span>
<span>2026.04.09</span>
</div>

<div class="headline">k-skill — 귀찮은 건 AI 에이전트에게 시키세요</div>
<div class="subhead">Claude Code, Codex, OpenCode 등 각종 코딩 에이전트에서 바로 사용 가능</div>

<div class="article-body">
<div>

<div class="key-figure">
<strong>26+</strong>개 한국 생활 스킬
<br>SRT 예약 · KTX 예매 · 쿠팡 검색 · 미세먼지 조회
</div>

<div class="key-figure">
GitHub Stars <strong>2.3k</strong>
<br>MIT 라이선스 · API 키 없이 사용
</div>

<div class="key-figure">
한국인이라면 다운로드 해두세요.
<br>언젠가 무조건 쓸 때가 옵니다.
</div>

</div>
<div>

![w:480 article-img](Fig/k-skill-thumbnail.png)

<div class="caption">출처: GitHub NomaDamas/k-skill</div>

</div>
</div>
