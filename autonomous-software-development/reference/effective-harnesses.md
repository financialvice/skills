---
title: "Effective harnesses for long-running agents \ Anthropic"
url: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
date: 2025-11-26
---

# Effective harnesses for long-running agents

Agents struggle across multiple context windows. Each session starts with no memory of prior work. Solution: initializer agent + coding agent pattern. Code examples: https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding

## Problem

Even Opus 4.5 with compaction fails at complex tasks like "build a claude.ai clone":

1. One-shotting: tries to do everything at once, runs out of context mid-feature, leaves undocumented mess
2. Premature completion: sees some progress, declares job done

Need: initial scaffolding for all features + incremental progress with clean handoffs between sessions.

## Solution

### 1. Initializer Agent (first session only)

Sets up:
- `init.sh` script for environment
- `claude-progress.txt` log file
- Initial git commit
- Comprehensive feature list (JSON, not Markdown - model less likely to inappropriately edit JSON)

Feature list example:
```json
{
  "category": "functional",
  "description": "New chat button creates fresh conversation",
  "steps": ["Navigate to interface", "Click New Chat", "Verify creation"],
  "passes": false
}
```

All features start as `"passes": false`. Prompt strongly: "unacceptable to remove or edit tests."

### 2. Coding Agent (every subsequent session)

Session start sequence:
1. `pwd` - confirm working directory
2. Read git logs + progress files
3. Read feature list, pick highest-priority incomplete feature
4. Run `init.sh`, test basic functionality before implementing anything

Work incrementally:
- One feature at a time
- Git commit with descriptive messages after each change
- Update progress file
- Leave environment in clean, mergeable state

### Testing

Critical: Claude marks features complete without proper e2e testing. Must explicitly prompt to use browser automation (Puppeteer MCP) and test as human would.

Limitation: Claude can't see browser-native alerts via Puppeteer, causing bugs in those features.

## Summary Table

| Problem | Initializer Solution | Coding Agent Solution |
|---------|---------------------|----------------------|
| Declares victory early | Feature list JSON with all requirements | Read feature list, work on single feature |
| Leaves buggy/undocumented state | Init git repo + progress file | Read progress + git log at start, commit + update at end |
| Marks features done prematurely | Feature list file | Self-verify with e2e testing before marking "passes" |
| Wastes time figuring out env | Write `init.sh` | Read and run `init.sh` |

## Open Questions

- Single general agent vs multi-agent (testing agent, QA agent, cleanup agent)?
- Generalizing beyond web dev to scientific research, financial modeling, etc.
