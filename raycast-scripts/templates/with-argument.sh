#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search Web
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔍
# @raycast.packageName Web Searches
# @raycast.argument1 { "type": "text", "placeholder": "Search query", "percentEncoded": true }

open "https://www.google.com/search?q=$1"
