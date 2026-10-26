#!/bin/sh
if uname -s | grep -q Darwin; then
  top -l 1 -n 0 | awk -F'[ ,%]+' '/CPU usage:/ {print int($3+$5); exit}'
else
  top -bn1 | awk -F'[ ,%]+' '/%Cpu/ {print int($3+$5); exit}'
fi
