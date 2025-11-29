---
name: instantdb
description: General knowledge and best practices for working with InstantDB, a modern real-time database ("Modern Firebase"). Use this skill whenever the user asks about InstantDB, wants to build with InstantDB, debug InstantDB issues, work with instant-cli, or needs help with InstaQL queries, permissions, or schema design.
---

# InstantDB

## CRITICAL: First Step

**ALWAYS fetch and read the official AGENTS.md before doing any InstantDB work:**

```
WebFetch: https://www.instantdb.com/llm-rules/AGENTS.md
```

This file contains essential, up-to-date guidance on schema design, queries, permissions, React hooks, and common pitfalls. Do not skip this step.

## Additional Documentation

The llms.txt file provides an index of all InstantDB documentation:

```
WebFetch: https://www.instantdb.com/llms.txt
```

Use this to discover and fetch specific documentation pages (as markdown) when deeper context is needed on particular topics.

## Open Source Repository

InstantDB is open source: https://github.com/instantdb/instant

**For deeper understanding, debugging, or building custom tooling:**

1. Clone the repo into a temporary directory:
   ```bash
   git clone https://github.com/instantdb/instant.git /tmp/instant
   ```

2. Search through the source code for implementation details - this is the ultimate source of truth when documentation is insufficient.

## CLI Usage

InstantDB's CLI is accessible via:

```bash
bunx instant-cli@latest
```

**ALWAYS run with `-h` first to learn available commands before using:**

```bash
bunx instant-cli@latest -h
```

This ensures you understand the current CLI interface and available options.
