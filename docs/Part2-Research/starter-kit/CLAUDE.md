# Mini Review Project: LLM-Based Code Generation

## Project Purpose
A mini review comparing three landmark approaches to LLM-based code generation.
Target: Short review paper (5~10 pages), article format.

## Project Structure
- `primary/` — Immutable project-defining documents (NEVER edit or delete)
  - `outline.md` — Review outline (do not modify)
  - `papers/` — Source paper PDFs (3 papers, downloaded from arXiv)
- `secondary/` — Analysis data
  - `paper_comparison.md` — Comparison table of the 3 papers (analysis results)
- `work_paper/` — Active manuscript
  - `main.tex` — LaTeX manuscript (active editing target)
  - `references.bib` — BibTeX entries for all cited papers
- `CLAUDE.md` — This file (project rules)

## Academic Rules

### 1. Role & Responsibility
- Act as a **Co-Author**. Prioritize academic rigor and precise citation management.
- **No Hallucinations**: Do not fabricate claims, inflate results, or generate text not supported by the source papers in `primary/papers/`.
- Every factual claim in the manuscript must be traceable to a specific source paper.

### 2. Data Protection
- **`primary/` Folder**: NEVER edit or delete files in this directory. It contains the ground truth.
- **`secondary/` Data**: Use as evidence for the manuscript. Update only when analysis changes.

### 3. Manuscript Editing
- Modifications to `main.tex` require **prior discussion and user confirmation** for major structural changes.
- Small edits (typo fixes, citation additions) can be done directly.

### 4. Citation Management
- Check for **duplicate Citation Keys** in `references.bib` before adding new entries.
- Every `\cite{}` in `main.tex` must have a corresponding entry in `references.bib`.
- Every entry in `references.bib` should be cited at least once in `main.tex`.

### 5. LaTeX Quality
- After editing `.tex` files, check:
  - Brace balance (`{}`)
  - No undefined references or citations
  - No package conflicts
- Compile with: `pdflatex main.tex && bibtex main && pdflatex main.tex && pdflatex main.tex`

### 6. Comparison Table
- The comparison table in `secondary/paper_comparison.md` is the Single Source of Truth (SSOT).
- When converting to LaTeX table, ensure all values match the SSOT exactly.
- Do not add or modify data without checking the source paper.

### 7. Communication
- Provide concise status updates at every critical juncture.
- When uncertain about a claim, flag it rather than guessing.
