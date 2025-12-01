---
name: heroui-native
description: Guide for building mobile UI with HeroUI Native components. Use when implementing React Native / Expo mobile interfaces, creating mobile components, or when the user mentions "heroui", "heroui-native", "mobile UI", or asks to build mobile app screens. This skill ensures proper reference to HeroUI Native's example app showcases before implementation.
---

# HeroUI Native

HeroUI Native is the mobile UI component library for our projects (shadcn/ui is for web).

- **Source**: https://github.com/heroui-inc/heroui-native
- **Example App**: https://github.com/heroui-inc/heroui-native-example

## Implementation Workflow

**Always follow this workflow before implementing any HeroUI Native components:**

### 1. Search Existing Implementations

Search the current repo for existing HeroUI Native usage:

```bash
# Find existing heroui-native imports and patterns
grep -r "heroui-native" --include="*.tsx" --include="*.ts"
```

### 2. Clone Reference Examples

Use degit to get the example app (contains critical showcases):

```bash
bunx degit heroui-inc/heroui-native-example tmp/heroui-native-example
```

For source code reference (if needed):

```bash
bunx degit heroui-inc/heroui-native tmp/heroui-native
```

### 3. Review Showcases First

**Critical**: Before implementing, review relevant showcases in `tmp/heroui-native-example/src/app/(home)/showcases/`:

| Showcase | Path | Use For |
|----------|------|---------|
| Cooking Onboarding | `showcases/cooking-onboarding.tsx` | Multi-step onboarding flows |
| Linear Task | `showcases/linear-task.tsx` | Task/item management UI |
| Onboarding | `showcases/onboarding.tsx` | Welcome/intro screens |
| Paywall | `showcases/paywall.tsx` | Subscription/pricing screens |
| Raycast | `showcases/raycast.tsx` | Command palette/search UI |

### 4. Review Component Demos

Component demos are in `tmp/heroui-native-example/src/app/(home)/components/`:

Accordion, Avatar, Button, Card, Checkbox, Chip, Dialog, DialogNativeModal, Divider, ErrorView, FormField, Popover, PopoverNativeModal, RadioGroup, ScrollShadow, Select, SelectNativeModal, Skeleton, Spinner, Surface, Switch, Tabs, TextField

### 5. Plan Before Implementing

Before writing code, document:

1. Which component(s) to use
2. How to compose them for the specific use case
3. Any edge cases or special considerations
4. How this differs from or extends the showcase patterns
