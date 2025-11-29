#!/usr/bin/env python3

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title API Example
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🌐
# @raycast.packageName API Tools
# @raycast.argument1 { "type": "text", "placeholder": "Endpoint" }

import sys
import json
import urllib.request
import urllib.error

def fetch_json(url):
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            return json.loads(response.read().decode())
    except urllib.error.URLError as e:
        print(f"Error: {e.reason}")
        sys.exit(1)
    except json.JSONDecodeError:
        print("Error: Invalid JSON response")
        sys.exit(1)

endpoint = sys.argv[1] if len(sys.argv) > 1 else "https://api.github.com"
data = fetch_json(endpoint)
print(json.dumps(data, indent=2))
