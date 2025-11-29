#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Process Clipboard
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Clipboard Tools

import subprocess

def get_clipboard():
    return subprocess.run(['pbpaste'], capture_output=True, text=True).stdout

def set_clipboard(text):
    subprocess.run(['pbcopy'], input=text, text=True)

# Get clipboard content
content = get_clipboard()

# Process it (example: convert to uppercase)
result = content.upper()

# Set back to clipboard
set_clipboard(result)

print(f"Converted to uppercase ({len(result)} chars)")
