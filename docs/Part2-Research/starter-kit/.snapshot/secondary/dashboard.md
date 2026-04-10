---
cssclasses: [dashboard]
title: "Research Dashboard"
---

# LLM Code Generation — Research Dashboard

## Review Progress

```dataview
TABLE status AS "상태", year AS "연도", approach AS "접근법", performance AS "대표 성능(%)"

WHERE type = "paper"
SORT year ASC
```

## Performance Comparison

```dataview
TABLE
    approach AS "접근법",
    benchmark AS "벤치마크",
    performance AS "성능(%)"

WHERE type = "paper" AND performance != null
SORT performance DESC
```

## Outline Preview

![[outline]]

## Figure / Table Plan

### Figures

```dataview
TABLE fig_title AS "Figure", fig_section AS "섹션", fig_method AS "제작 방식"

WHERE fig_title != null
```

### Tables

```dataview
TABLE tbl_title AS "Table", tbl_section AS "섹션", tbl_data_source AS "데이터 출처"

WHERE tbl_title != null
```

## Concept Map

```dataview
TABLE length(file.inlinks) AS "참조 수", sources AS "원본"

WHERE type = "concept"
SORT length(file.inlinks) DESC
```

## Recently Updated

```dataview
TABLE last_compiled AS "최종 업데이트"

WHERE last_compiled != null
SORT last_compiled DESC
LIMIT 10
```
