#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title System Stats
# @raycast.mode inline
# @raycast.refreshTime 30s

# Optional parameters:
# @raycast.icon 💻
# @raycast.packageName Dashboard

# Get CPU usage
cpu=$(top -l 1 | grep "CPU usage" | awk '{print $3}')
# Get memory pressure
mem=$(memory_pressure | grep "System-wide memory free percentage" | awk '{print 100-$5"%"}')

echo "CPU: $cpu | Mem: $mem"
