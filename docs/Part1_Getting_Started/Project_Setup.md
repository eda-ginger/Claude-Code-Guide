# 프로젝트 설정 가이드

이 문서에서는 Claude Code를 프로젝트에 최적화하기 위한 **설정 파일 구조, CLAUDE.md 작성법, 권한 설정** 등을 안내합니다.

## 1. CLAUDE.md — 프로젝트 컨텍스트 파일

`CLAUDE.md`는 Claude Code가 프로젝트를 이해하는 데 사용하는 핵심 파일입니다. 프로젝트 루트에 이 파일을 두면 Claude가 자동으로 읽어들입니다.

### 1.1 CLAUDE.md에 포함할 내용

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 빌드 및 실행 방법
- npm install && npm run build
- npm test (단일 테스트: npm test -- --grep "테스트명")

## 프로젝트 구조
- src/ — 소스 코드
- tests/ — 테스트 파일

## 코딩 컨벤션
- TypeScript strict 모드 사용
- 함수명은 camelCase
```

### 1.2 CLAUDE.md 계층 구조

CLAUDE.md는 여러 위치에 둘 수 있으며, 계층적으로 적용됩니다.

| 위치 | 적용 범위 |
|------|-----------|
| `~/.claude/CLAUDE.md` | 모든 프로젝트에 공통 적용 |
| `프로젝트루트/CLAUDE.md` | 해당 프로젝트 전체 |
| `프로젝트루트/src/CLAUDE.md` | src 디렉토리 내 작업 시 추가 적용 |

> 하위 디렉토리의 CLAUDE.md는 상위를 **덮어쓰지 않고 추가(append)** 됩니다.

### 1.3 `/init` 명령어로 자동 생성

프로젝트에 CLAUDE.md가 없다면, Claude Code 내에서 `/init` 명령을 실행하면 프로젝트를 분석하여 자동으로 생성해줍니다.

```
> /init
```

## 2. settings.json — 동작 설정 파일

Claude Code의 동작을 세부적으로 제어하는 JSON 설정 파일입니다.

### 2.1 설정 파일 위치

| 파일 | 위치 | 용도 |
|------|------|------|
| 전역 설정 | `~/.claude/settings.json` | 모든 프로젝트 공통 |
| 프로젝트 설정 (공유) | `.claude/settings.json` | 팀 공유용 (Git 커밋 대상) |
| 프로젝트 설정 (개인) | `.claude/settings.local.json` | 개인용 (`.gitignore` 대상) |

### 2.2 설정 예시

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git *)",
      "Read",
      "Edit"
    ],
    "deny": [
      "Bash(rm -rf *)"
    ]
  },
  "env": {
    "NODE_ENV": "development"
  }
}
```

### 2.3 주요 설정 항목

- **`permissions.allow`**: 자동 승인할 도구 및 명령 패턴
- **`permissions.deny`**: 항상 차단할 명령 패턴
- **`env`**: Claude Code 실행 시 적용할 환경 변수

## 3. .claudeignore — 파일 제외 설정

`.gitignore`와 같은 문법으로, Claude Code가 읽지 않을 파일/폴더를 지정합니다.

```
# .claudeignore 예시
node_modules/
dist/
*.min.js
.env
secrets/
```

## 4. 프로젝트 설정 권장 사항

1. **CLAUDE.md를 우선 작성**: 빌드 명령어, 테스트 방법, 주요 구조를 기록
2. **permissions은 최소 권한 원칙**: 필요한 명령만 `allow`에 추가
3. **.claudeignore로 불필요한 파일 제외**: `node_modules`, 빌드 산출물, 시크릿 파일 등
4. **팀 설정은 `.claude/settings.json`에**: 개인 설정은 `settings.local.json`에 분리

---
> 💡 **Tip:** 프로젝트 초기에 CLAUDE.md를 잘 작성해두면, 이후 Claude Code와의 모든 대화에서 불필요한 반복 설명 없이 바로 작업에 들어갈 수 있습니다.
