#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert Case
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔤
# @raycast.packageName Text Tools
# @raycast.argument1 { "type": "dropdown", "placeholder": "Case type", "data": [{"title": "UPPERCASE", "value": "upper"}, {"title": "lowercase", "value": "lower"}, {"title": "Title Case", "value": "title"}] }

text=$(pbpaste)

case "$1" in
  "upper")
    result=$(echo "$text" | tr '[:lower:]' '[:upper:]')
    ;;
  "lower")
    result=$(echo "$text" | tr '[:upper:]' '[:lower:]')
    ;;
  "title")
    result=$(echo "$text" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    ;;
esac

echo "$result" | pbcopy
echo "Converted to $1"
