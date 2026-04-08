# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

Claude Code의 다양한 기능을 실습하고 테스트하기 위한 **한국어 가이드 문서 저장소**입니다. 소스 코드가 아닌 마크다운 문서(.md)로 구성됩니다.

## 문서 구조

- `README.md` — 프로젝트 소개 및 가이드 목차 (Table of Contents)
- `docs/Part1-Basic/` — 기본 가이드 (읽고 이해하는 이론 문서)
- `docs/Part2-Setup/` — 실전 환경 구축 (Claude에게 보여주면 세팅+활용까지 안내)
- `docs/Part3-Research/` — 연구·학습 활용 (연구 워크플로에 Claude Code 활용)
- `docs/Part4-Life/` — 일상·생활 활용 (Obsidian, 한국 생활 스킬 등)
- `docs/Part5-Appendix/` — 부록·레퍼런스 (상태 표시줄, 텔레그램 등 상세 문서)
- `docs/Part{N}_{영문}/{NN}_{영문}.md` — 번호가 매겨진 가이드 문서 (예: `01_Installation_and_Run.md`)

## 문서 작성 규칙

- 모든 가이드 문서는 **한국어**로 작성
- 폴더명은 `Part{번호}_{영문_제목}` 형식 (예: `Part1-Basic`, `Part2_Practical_Setup`)
- 파일명은 `{NN}_{영문_제목}.md` 형식 (예: `01_Installation_and_Run.md`)
- 새 가이드 문서를 추가하면 반드시 `README.md`의 해당 **Part 테이블**에 링크 추가
- 각 문서는 `# 한국어 제목` 형식의 H1 헤더로 시작
- 코드 블록에는 언어 태그 명시 (```bash, ```json 등)
