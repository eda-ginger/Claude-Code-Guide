---
title: "Codex: Evaluating Large Language Models Trained on Code"
type: paper
status: "📋 대기"
authors: "Chen et al. (OpenAI)"
year: 2021
approach: "GPT fine-tuning on GitHub code (closed-source)"
dataset: "159 GB Python code from 54M GitHub repos"
performance: 37.7
benchmark: "HumanEval pass@1 (Codex-S-12B)"
sources:
  - "primary/papers/01_Codex_2021.pdf"
related:
  - "[[alphacode_summary]]"
  - "[[codellama_summary]]"
  - "[[fine-tuning]]"
  - "[[benchmark-evaluation]]"
  - "[[sampling-strategies]]"
last_compiled: 2026-04-09
---

## 목적

GPT 언어 모델을 공개 코드에 fine-tuning하여 Python 코드 생성 능력을 평가. GitHub Copilot의 기반 모델.

## 방법론

- **기반 모델**: GPT-3 아키텍처 (최대 12B 파라미터)
- **학습 데이터**: 2020년 5월 GitHub 스냅샷, 54M 공개 레포에서 159 GB Python 코드 수집
- **토크나이저**: GPT-3 텍스트 토크나이저 기반, 공백 표현 최적화 (약 30% 토큰 절감)
- **학습**: 100B 토큰 학습, Adam 옵티마이저 (β₁=0.9, β₂=0.95), 175-step linear warmup
- **Codex-S**: Supervised fine-tuning 버전. 경쟁 프로그래밍 + CI 트레이싱으로 수집한 문제-솔루션 쌍으로 추가 학습
- **추론**: Nucleus sampling (top-p=0.95), temperature 0.8

## 주요 결과

| 모델 | HumanEval pass@1 | HumanEval pass@100 |
|------|------------------|--------------------|
| GPT-3 12B | 0% | - |
| GPT-J 6B | 11.4% | - |
| Codex-12B | 28.81% | 72.31% |
| Codex-S-12B | 37.7% | - |

- 100개 샘플 생성 시 HumanEval 문제의 77.5% 해결 가능 (mean log-prob 선택)
- Test loss는 모델 크기에 대해 power law 스케일링 (GPT-3와 유사)
- BLEU score는 functional correctness의 좋은 지표가 아님을 입증

## 핵심 기여

1. **HumanEval 벤치마크 제안**: 164개 수작업 프로그래밍 문제 + unit test, functional correctness 평가의 표준
2. **pass@k 메트릭 정의**: 비편향 추정량 공식 제안, 이후 코드 생성 연구의 표준 평가 지표
3. **코드 fine-tuning 스케일링**: 코드 fine-tuning 후에도 test loss의 power law 관계 유지됨을 확인
4. **샘플 선택 전략**: mean log-probability 기반 reranking이 random 선택보다 우수

## 한계

- **샘플 효율성 부족**: 학습에 수십억 줄의 코드 필요 (초보 CS 학생보다 더 많은 데이터)
- **긴 docstring 어려움**: 연산과 변수 바인딩의 체인이 길어지면 성능 급감 (Figure 11)
- **시스템 수준 합성 불가**: 독립 함수 수준에 국한, 복잡한 프로젝트 수준 코드 생성 불가
- **정렬 문제**: 미묘한 버그가 있는 코드를 의도적으로 생성할 수 있음 (misalignment, Figure 12)
- **보안 리스크**: 안전하지 않은 코드 제안 가능성

## BibTeX

```bibtex
@article{chen2021evaluating,
  title={Evaluating Large Language Models Trained on Code},
  author={Chen, Mark and Tworek, Jerry and Jun, Heewoo and Yuan, Qiming and others},
  journal={arXiv preprint arXiv:2107.03374},
  year={2021}
}
```
