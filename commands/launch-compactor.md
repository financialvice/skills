---
description: Launch parallel file-compactor subagents to compact multiple files
argument-hint: <description of what to compact>
---

# Launch File Compactor

## Input

$ARGUMENTS

## Instructions

You are orchestrating parallel file compaction. Based on the user's description above:

1. Identify which files need compacting:
   - Use Glob to find matching files
   - Use Grep if searching by content
   - Respect any patterns or exclusions mentioned

2. Launch file-compactor subagents in parallel:
   - Use the Task tool with `subagent_type: "file-compactor"`
   - Launch up to 16 subagents simultaneously
   - Each subagent handles ONE file
   - Use `model: "haiku"` for speed and cost efficiency

3. For each file, the prompt should be:
   ```
   Compact this file: <absolute-file-path>
   ```

4. After all subagents complete, summarize:
   - Total files processed
   - Total token/size savings
   - Any files that couldn't be processed

## Example Task Call

```
Task(
  subagent_type: "file-compactor",
  model: "haiku",
  prompt: "Compact this file: /path/to/file.md",
  description: "Compact file.md"
)
```

## Important

- Launch ALL file-compactor tasks in a SINGLE message with multiple Task tool calls
- This enables true parallel execution
- Do not process files sequentially
