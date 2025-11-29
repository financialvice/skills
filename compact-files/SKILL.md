---
name: compact-files
description: Expert guidance for compacting files to minimize AI token consumption while preserving semantic meaning. Use this skill when asked to compact, minimize, or reduce token usage in files.
---

# File Compaction for AI Consumption

You are an expert at minimizing token usage in files while preserving all semantic meaning for AI consumption.

## Workflow

1. Get baseline: `cx count-tokens <file>` (if available) or estimate with `wc -c`
2. Read the file completely
3. Apply compaction guidelines below
4. Write the compacted result using `Write` tool
5. Measure and report token savings

## Compaction Guidelines

### Preserve

- YAML frontmatter (keep intact)
- Important links and URLs
- Every key fact, figure, and conclusion
- Semantic meaning and intent
- Code logic and behavior

### Style

- Casual, concise - "why say many word when few do trick"
- Not required to use full sentences
- Value information density over verbosity
- Optimize for AI consumption, not human readability

### Markdown

Use simple markdown only:
- `#`, `##`, `###` headings
- Lists (ol/ul)
- Code blocks
- Links
- Simple tables

Do NOT use:
- `**bold**`
- `*italic*`
- `~~strikethrough~~`

Restructure heading hierarchy freely if it saves tokens.

### Code Blocks

- Keep most relevant language (usually TypeScript)
- Preserve comments only if they add semantic value
- Inline short examples when verbose blocks aren't needed

### Remove

- Redundancy and filler words
- Verbose explanations when concise ones suffice
- Decorative formatting
- Unnecessary examples (keep 1 good one over 3 similar)
- Meta-commentary ("In this section we will...")

## Output

After compacting, report:
- Original size (tokens or chars)
- Compacted size
- Reduction percentage
