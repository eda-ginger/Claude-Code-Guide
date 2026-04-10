---
title: "AlphaCode: Competition-Level Code Generation"
type: paper
status: "📋 대기"
authors: "Li et al. (DeepMind)"
year: 2022
approach: "Encoder-decoder transformer, massive sampling + filtering/clustering"
dataset: "715.1 GB GitHub code (pre-training) + CodeContests (fine-tuning)"
performance: 54.3
benchmark: "Codeforces top ranking (41B+clustering)"
sources:
  - "primary/papers/02_AlphaCode_2022.pdf"
related:
  - "[[codex_summary]]"
  - "[[codellama_summary]]"
  - "[[sampling-strategies]]"
  - "[[benchmark-evaluation]]"
  - "[[fine-tuning]]"
last_compiled: 2026-04-09
---

## 목적

경쟁 프로그래밍 수준의 코드 생성 시스템 개발. 단순 번역이 아닌 알고리즘적 추론이 필요한 복잡한 문제 해결.

## 방법론

- **아키텍처**: Encoder-decoder transformer (비대칭: 얕은 인코더 + 깊은 디코더)
  - 모델 크기: 300M, 1B, 2.8B, 9B, 41B
  - Multi-query attention으로 샘플링 효율 향상 (4.74 samples/TPU sec for 1.15B)
- **Pre-training**: GitHub 715.1 GB 코드 (C++, Python, Java 등 다중 언어), standard LM + masked LM loss
- **Fine-tuning**: CodeContests 데이터셋 (13,328 train problems from Codeforces)
  - GOLD (offline RL) + tempering + value conditioning + tags/ratings conditioning
  - 시간 분할: 학습 데이터(~2021/07) → 검증(2021/07~09) → 테스트(2021/09~)
- **대량 샘플링**: 문제당 최대 100만 개 샘플 생성
  - Python/C++ 각 절반, 태그/난이도 랜덤 조건부
- **필터링**: example test 통과 샘플만 선택 (99% 제거)
- **클러스터링**: 생성된 테스트 입력에 대한 출력 기반 프로그램 클러스터링, 각 클러스터에서 대표 선택

## 주요 결과

| 설정 | Validation | Test |
|------|-----------|------|
| 41B+clustering 10@1k | 21.0% | 16.4% |
| 41B+clustering 10@10k | 26.2% | 25.4% |
| 41B+clustering 10@100k | 31.8% | 29.6% |
| 41B+clustering 10@1M | 34.2% | - |

- Codeforces 10개 시뮬레이션 대회에서 **평균 상위 54.3%**, 예상 레이팅 1238 (상위 28%)
- 최초로 경쟁 프로그래밍에서 인간 수준에 도달한 시스템
- Solve rate는 샘플 수에 대해 log-linear 스케일링
- 모델 향상 (Table 8): No enhancement → +GOLD+clustering로 10@100k가 15.2% → 24.1%

## 핵심 기여

1. **대량 샘플링+필터링 패러다임**: 수백만 개 생성 → 테스트 필터링 → 클러스터링 → 10개 제출
2. **CodeContests 데이터셋**: 시간 분할 + 추가 생성 테스트로 false positive 4%로 감소 (기존 30-60%)
3. **비대칭 인코더-디코더**: 얕은 인코더 + 깊은 디코더가 학습 효율과 성능 모두에서 유리
4. **스케일링 분석**: 모델 크기, 샘플 수, 컴퓨트 모두에 대해 log-linear 스케일링 확인

## 한계

- **샘플 효율 극히 낮음**: 문제당 100만 개 생성으로 막대한 컴퓨트 소비
- **문제 설명 민감도**: 사소한 변형에도 성능 크게 변화 (Section 6.3)
- **메타데이터 의존**: 태그/난이도 조건부 학습이 성능에 영향
- **검증 손실과 성능 괴리**: validation loss가 solve rate의 좋은 프록시가 아님 (Section 6.5)
- **클로즈드 소스**: 모델 가중치 비공개

## BibTeX

```bibtex
@article{li2022competition,
  title={Competition-Level Code Generation with AlphaCode},
  author={Li, Yujia and Choi, David and Chung, Junyoung and Kushman, Nate and others},
  journal={arXiv preprint arXiv:2203.07814},
  year={2022}
}
```
