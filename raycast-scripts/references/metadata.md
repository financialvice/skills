# Raycast Script Command Metadata Reference

Complete reference for all available metadata parameters.

## Required Parameters

| Parameter | Description |
|-----------|-------------|
| `schemaVersion` | Always `1` |
| `title` | Display name in Raycast search |
| `mode` | Output mode: `silent`, `compact`, `fullOutput`, `inline` |

## Optional Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `packageName` | Subtitle in search (defaults to directory name) | `Web Searches` |
| `icon` | Emoji, file path, or HTTPS URL (64px recommended) | `🔍` or `images/icon.png` |
| `iconDark` | Icon for dark mode (falls back to `icon`) | `images/icon-dark.png` |
| `currentDirectoryPath` | Working directory for script | `~` or `/usr/local/bin` |
| `needsConfirmation` | Show confirmation before running | `true` |
| `refreshTime` | Auto-refresh for inline mode | `10s`, `5m`, `1h`, `1d` |
| `description` | Brief description of the command | `Convert hex color to RGB` |
| `author` | Author name | `John Doe` |
| `authorURL` | Author link (GitHub, Twitter, etc.) | `https://github.com/johndoe` |

## Arguments (1-3)

```
# @raycast.argument1 { "type": "text", "placeholder": "Input" }
# @raycast.argument2 { "type": "password", "placeholder": "API Key" }
# @raycast.argument3 { "type": "dropdown", "placeholder": "Format", "data": [...] }
```

### Argument Fields

| Field | Description | Required |
|-------|-------------|----------|
| `type` | `text`, `password`, or `dropdown` | Yes |
| `placeholder` | Input field placeholder text | Yes |
| `optional` | Set `true` to make optional | No |
| `percentEncoded` | URL-encode value before passing | No |
| `data` | Array of `{title, value}` for dropdowns | Yes (dropdown) |

### Dropdown Example

```
# @raycast.argument1 { "type": "dropdown", "placeholder": "Choose", "data": [{"title": "Option A", "value": "a"}, {"title": "Option B", "value": "b"}] }
```

## Output Modes Detail

### silent
- Raycast closes immediately
- Last line shown as HUD overlay
- Best for: clipboard ops, opening URLs, quick actions

### compact
- Toast notification with last line
- Raycast stays open
- Best for: simple confirmations, short results

### fullOutput
- Terminal-like scrollable view
- Supports ANSI colors
- Best for: multi-line output, logs, formatted text

### inline
- Shows in command list itself
- Requires `refreshTime` parameter
- Auto-refreshes at specified interval
- Best for: dashboard widgets, live data
- Limit: First 10 inline commands auto-refresh

## ANSI Color Codes

For `inline` and `fullOutput` modes:

| Color | Foreground | Background |
|-------|------------|------------|
| Black | 30 | 40 |
| Red | 31 | 41 |
| Green | 32 | 42 |
| Yellow | 33 | 43 |
| Blue | 34 | 44 |
| Magenta | 35 | 45 |
| Cyan | 36 | 46 |
| White | 97 | 107 |

```bash
echo -e '\033[31;42mRed on green\033[0m'
```

Special codes: `0` (reset), `4` (underline), `9` (strikethrough)

## Comment Syntax by Language

| Language | Comment Style |
|----------|---------------|
| Bash, Python, Ruby, AppleScript | `# @raycast.param value` |
| JavaScript, Swift, PHP | `// @raycast.param value` |

## Shebangs

| Language | Shebang |
|----------|---------|
| Bash | `#!/bin/bash` |
| Python | `#!/usr/bin/env python3` |
| Node.js | `#!/usr/bin/env node` |
| Swift | `#!/usr/bin/swift` |
| AppleScript | `#!/usr/bin/osascript` |
| Ruby | `#!/usr/bin/env ruby` |
| PHP | `#!/usr/bin/env php` |

## Exit Codes

- `0` = Success
- Non-zero = Failure (shows error toast with last output line)

## Tips

- Use `#!/bin/bash -l` for login shell (access to PATH)
- `/usr/local/bin` is auto-appended to PATH
- Long-running commands may not work in compact/silent modes
- Use `zip -q` (quiet) for zip operations in non-fullOutput modes
