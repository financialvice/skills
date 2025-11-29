---
name: raycast-scripts
description: Create Raycast script commands for macOS automation. Use when users request creating Raycast scripts, script commands, or want to automate tasks in Raycast. Supports Bash, Python, Node.js, Swift, AppleScript, and Ruby. Handles arguments, output modes (silent, compact, fullOutput, inline), and dashboard widgets.
---

# Raycast Script Commands

Create executable scripts for Raycast on macOS. Scripts use comment-based metadata and can be written in Bash, Python, Node.js, Swift, AppleScript, or Ruby.

## Quick Start

Generate a script with the required metadata header:

```bash
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title My Script
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName My Tools

echo "Hello from Raycast"
```

## Script Structure

Every script needs:
1. **Shebang** - `#!/bin/bash`, `#!/usr/bin/env python3`, etc.
2. **Required metadata** - schemaVersion, title, mode
3. **Optional metadata** - icon, packageName, arguments, etc.
4. **Script body** - the actual code

## Output Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| `silent` | Shows HUD toast with last line | Quick confirmations, clipboard operations |
| `compact` | Shows toast with last line | Simple status messages |
| `fullOutput` | Shows terminal-like view | Multi-line output, logs |
| `inline` | Shows in command list, auto-refreshes | Dashboard widgets (requires `refreshTime`) |

## Arguments

Up to 3 arguments with JSON config:

```bash
# @raycast.argument1 { "type": "text", "placeholder": "Search query" }
# @raycast.argument2 { "type": "text", "placeholder": "Optional", "optional": true }
# @raycast.argument3 { "type": "dropdown", "placeholder": "Format", "data": [{"title": "JSON", "value": "json"}, {"title": "CSV", "value": "csv"}] }
```

Argument types: `text`, `password`, `dropdown`

Options: `placeholder` (required), `optional`, `percentEncoded`, `data` (for dropdowns)

Access in scripts: `$1`, `$2`, `$3` (bash) or `sys.argv[1]` (python) or `process.argv[2]` (node)

## Language Templates

### Bash
```bash
#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Script Name
# @raycast.mode silent
# @raycast.icon 🔧
# @raycast.packageName Tools

# @raycast.argument1 { "type": "text", "placeholder": "Input" }

echo "Result: $1"
```

### Python
```python
#!/usr/bin/env python3

# @raycast.schemaVersion 1
# @raycast.title Script Name
# @raycast.mode compact
# @raycast.icon 🐍
# @raycast.packageName Tools

import sys
print(f"Result: {sys.argv[1]}")
```

### Node.js
```javascript
#!/usr/bin/env node

// @raycast.schemaVersion 1
// @raycast.title Script Name
// @raycast.mode fullOutput
// @raycast.icon 📦
// @raycast.packageName Tools

const [,, arg1] = process.argv;
console.log(`Result: ${arg1}`);
```

### Swift
```swift
#!/usr/bin/swift

// @raycast.schemaVersion 1
// @raycast.title Script Name
// @raycast.mode silent
// @raycast.icon 🍎
// @raycast.packageName Tools

print("Hello from Swift")
```

### AppleScript
```applescript
#!/usr/bin/osascript

# @raycast.schemaVersion 1
# @raycast.title Script Name
# @raycast.mode silent
# @raycast.icon 📜
# @raycast.packageName Tools

on run argv
  log "Hello: " & (item 1 of argv)
end run
```

## Dashboard (Inline Mode)

For live-updating dashboard widgets:

```bash
#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title CPU Usage
# @raycast.mode inline
# @raycast.refreshTime 30s
# @raycast.icon 💻
# @raycast.packageName Dashboard

top -l 1 | grep "CPU usage" | awk '{print $3}'
```

Refresh intervals: `10s` minimum, supports `s`, `m`, `h`, `d`

## Common Patterns

### Clipboard Operations
```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Copy UUID
# @raycast.mode silent
# @raycast.icon 📋

uuidgen | tr -d '\n' | pbcopy
echo "UUID copied"
```

### Web Search
```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Search Google
# @raycast.mode silent
# @raycast.icon 🔍
# @raycast.argument1 { "type": "text", "placeholder": "query", "percentEncoded": true }

open "https://google.com/search?q=$1"
```

### API Call
```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Bitcoin Price
# @raycast.mode inline
# @raycast.refreshTime 1h
# @raycast.icon ₿

curl -s "https://api.coindesk.com/v1/bpi/currentprice.json" | python3 -c "import json,sys; print('$' + json.load(sys.stdin)['bpi']['USD']['rate'])"
```

### Confirmation Dialog
```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Empty Trash
# @raycast.mode silent
# @raycast.icon 🗑️
# @raycast.needsConfirmation true

rm -rf ~/.Trash/*
echo "Trash emptied"
```

## Error Handling

Exit with non-zero code to show error toast:

```bash
if ! command -v jq &> /dev/null; then
  echo "jq is required"
  exit 1
fi
```

## ANSI Colors (inline/fullOutput)

```bash
echo -e '\033[31mRed text\033[0m'
echo -e '\033[32mGreen text\033[0m'
echo -e '\033[33mYellow text\033[0m'
```

## Metadata Reference

See [references/metadata.md](references/metadata.md) for complete metadata options.

## Installation

1. Save script to a directory (e.g., `~/.raycast-scripts/`)
2. Make executable: `chmod +x script.sh`
3. In Raycast: Settings → Extensions → Script Commands → Add Directory
