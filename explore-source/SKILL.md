---
name: explore-source
description: Explore external reference source code to understand implementations, draw inspiration, debug issues, or answer questions. Use when exploring repos like InstantDB, Trigger.dev, Vercel AI SDK, HeroUI Native, or any external codebase. Handles two modes - "inspiration" (adaptive, translating concepts to user's stack) or "understanding" (direct, definitive answers about the source). Always cite file:line references.
---

# Explore Source Code

## Determine Mode

Ask or infer which mode applies:

| Mode | When | Output Style |
|------|------|--------------|
| **Inspiration** | Replicating features, UI patterns, adapting concepts to different stack | Frame findings as "one approach" or "this implementation does X"; translate to user's tech (e.g., SQLite → InstantDB) |
| **Understanding** | Debugging, answering questions, understanding behavior, implementing the service/SDK directly | Direct, definitive statements about how code works |

## Setup

Clone with degit (shallow, no git history):
```bash
bunx degit <owner>/<repo> /tmp/<repo>
```

If degit fails (rate limits, etc.), fallback to shallow git clone:
```bash
git clone --depth 1 https://github.com/<owner>/<repo>.git /tmp/<repo>
```

## Frequently Visited Repos

### InstantDB (`instantdb/instant`)
```
client/packages/
├── core/          # @instantdb/core - vanilla JS, query/tx types, schema
├── react-common/  # shared React hooks (useQuery, usePresence, etc.)
├── react/         # @instantdb/react - re-exports react-common
├── react-native/  # @instantdb/react-native
├── admin/         # admin SDK
├── cli/           # instant-cli
└── mcp/           # MCP server
client/www/
├── pages/dash/    # dashboard UI (helpful for devtool features)
└── pages/docs/    # docs source
```

### Trigger.dev (`triggerdotdev/trigger.dev`)
```
packages/
├── trigger-sdk/   # main SDK (@trigger.dev/sdk)
├── core/          # shared core utilities
├── react-hooks/   # React integration
├── cli-v3/        # CLI tooling
└── rsc/           # React Server Components
apps/
├── webapp/        # dashboard UI
├── coordinator/   # job orchestration
└── supervisor/    # process management
```

### Vercel AI SDK (`vercel/ai`)
```
packages/
├── ai/            # main SDK (streamText, generateText, useChat, useCompletion)
├── react/         # React hooks
├── provider/      # provider abstraction layer
├── anthropic/     # Anthropic provider
├── openai/        # OpenAI provider
├── google/        # Google provider
└── [many more providers...]
content/
├── docs/          # documentation source
├── cookbook/      # examples and recipes
└── providers/     # provider-specific docs
```

### HeroUI Native (`heroui-inc/heroui-native`)
```
src/
├── components/    # UI components (button, card, checkbox, etc.)
├── primitives/    # base building blocks
├── providers/     # context providers
├── styles/        # styling utilities
└── helpers/       # shared helpers
example/           # example app
```

## Search Strategies

Use `warp_grep` MCP tool for natural language queries across the repo - it's faster and finds context intelligently.

Manual grep patterns when needed:
```bash
# Public API / exports
grep -rn "export " packages/core/src --include="*.ts" | head -30

# Find function implementation
grep -rn "function useQuery\|const useQuery" packages/

# Entry points (start here!)
cat packages/core/src/index.ts

# Tests = best docs
find . -name "*.test.ts" | xargs grep -l "describe.*featureName"
```

**Pro tips:**
- Start with `index.ts` or `package.json` exports to understand public API
- Tests often document edge cases better than code comments
- Look for `__tests__`, `*.test.ts`, or `*.spec.ts` files near features

## Output Guidelines

1. **Be concise** - bullet points over paragraphs
2. **Always cite** - `src/hooks/useChat.ts:47` format
3. **Show key code** - small snippets, not full files
4. **Inspiration mode**: "This implementation uses X, which could translate to Y in your stack"
5. **Understanding mode**: "The function does X at `file:line`"

## Common Intents

| Intent | Focus |
|--------|-------|
| Replicate feature | Entry points → component structure → state management → data flow |
| Replicate UI | Component props → styling approach → composition patterns |
| Implement SDK | Public API → internal types → request/response flow |
| Debug issue | Error sources → state mutations → edge cases in tests |
| Understand behavior | Function definition → call sites → data transformations |
