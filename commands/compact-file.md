---
description: Compact a file to minimize tokens while preserving key information for AI consumption
argument-hint: <file-path> [notes]
---

## Task: Compact File for AI Consumption

**File:** $1
**Notes:** $2

### Steps

1. Run `cx count-tokens $1` to get baseline token count
2. Read the file using the `Read` tool
3. Compact the content following the guidelines below
4. Write the compacted result:
   - If making small targeted edits (narrow objective), use `Edit` tool
   - If rewriting substantially (typical), use `Write` tool to replace file
5. Run `cx count-tokens $1` again to verify reduction and report savings

### Compaction Guidelines

**Preserve:**
- YAML frontmatter (keep intact)
- Important links and URLs
- Every key fact, figure, and conclusion
- Semantic meaning and intent
- Code logic and behavior

**Style:**
- Casual, concise - "why say many word when few do trick"
- Not required to use full sentences
- Value information density over verbosity
- Optimize for AI consumption, not human readability

**Markdown:**
- Use simple markdown only: `#`, `##`, `###`, lists (ol/ul), code blocks, links, simple tables
- Do NOT use text emphasis (`**bold**`, `*italic*`, `~~strike~~`)
- Not required to preserve original heading hierarchy - restructure freely if it saves tokens

**Code blocks:**
- If multiple languages shown, keep most relevant (usually TypeScript)
- Preserve code comments only if they add semantic value
- Inline short examples when verbose blocks aren't needed

**Remove:**
- Redundancy and filler words
- Verbose explanations when concise ones suffice
- Decorative formatting
- Unnecessary examples (keep 1 good one over 3 similar)
- Meta-commentary ("In this section we will...")
