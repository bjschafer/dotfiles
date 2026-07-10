#!/bin/bash
# Claude Code status line
# Format: CCCCCCCCCC ##% S:17% W:2% | ~/git/star-shift   branch-name
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
YELLOW=$'\033[93m'
GREEN=$'\033[92m'
BLUE=$'\033[96m'
MAGENTA=$'\033[95m'
RESET=$'\033[0m'
# Context bar
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
    pct_int=$(printf "%.0f" "$used_pct")
    bar_filled=$((pct_int / 10))
    bar_empty=$((10 - bar_filled))
    bar=""
    i=0
    while [ $i -lt $bar_filled ]; do
        bar="${bar}▓"
        i=$((i + 1))
    done
    i=0
    while [ $i -lt $bar_empty ]; do
        bar="${bar}░"
        i=$((i + 1))
    done
    context_part="${YELLOW}${bar} ${pct_int}%${RESET}"
else
    context_part="${YELLOW}░░░░░░░░░░ 00%${RESET}"
fi
# Usage info (cached, refreshed in background to keep status line fast).
# TTL is long and refreshes are mutex'd via a mkdir lock (portable, no flock
# dependency) because the usage endpoint rate-limits per-account, not
# per-session -- with several concurrent `claude` sessions each polling on
# their own timer, short TTLs collectively exceed the limit and /usage never
# succeeds.
USAGE_CACHE="/tmp/claude_usage_cache"
USAGE_LOCK="/tmp/claude_usage_cache.lock"
CACHE_TTL=1800  # 30 minutes
now=$(date +%s)
cache_age=9999
if [ -f "$USAGE_CACHE" ]; then
    cache_mtime=$(stat -c %Y "$USAGE_CACHE" 2>/dev/null || stat -f %m "$USAGE_CACHE" 2>/dev/null)
    cache_age=$((now - cache_mtime))
fi
if [ "$cache_age" -ge "$CACHE_TTL" ]; then
    if [ -d "$USAGE_LOCK" ]; then
        lock_mtime=$(stat -c %Y "$USAGE_LOCK" 2>/dev/null || stat -f %m "$USAGE_LOCK" 2>/dev/null)
        lock_age=$((now - lock_mtime))
        [ "$lock_age" -ge 60 ] && rmdir "$USAGE_LOCK" 2>/dev/null
    fi
    if mkdir "$USAGE_LOCK" 2>/dev/null; then
        (claude /usage 2>/dev/null > "${USAGE_CACHE}.tmp" && mv "${USAGE_CACHE}.tmp" "$USAGE_CACHE"
         rmdir "$USAGE_LOCK" 2>/dev/null) &
    fi
fi
usage_part=""
if [ -f "$USAGE_CACHE" ]; then
    usage_data=$(cat "$USAGE_CACHE")
    session_pct=$(echo "$usage_data" | grep -o 'Current session: [0-9]*%' | grep -o '[0-9]*')
    weekly_pct=$(echo "$usage_data" | sed -n 's/.*Current week (all models): \([0-9]*\)%.*/\1/p')
    fable_pct=$(echo "$usage_data" | sed -n 's/.*Current week (Fable): \([0-9]*\)%.*/\1/p')
    if [ -n "$session_pct" ] || [ -n "$weekly_pct" ] || [ -n "$fable_pct" ]; then
        usage_part=" ${MAGENTA}S:${session_pct:-?}% W:${weekly_pct:-?}%"
        if [ -n "$fable_pct" ]; then
            usage_part="${usage_part} F:${fable_pct}%"
        fi
        usage_part="${usage_part}${RESET}"
    fi
fi
# Directory
home="$HOME"
display_dir=$(echo "$cwd" | sed "s|^$home|~|")
# Git branch (skip optional locks to avoid contention)
branch_part=""
if git -C "$cwd" -c core.fsmonitor= rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>/dev/null ||
        git -C "$cwd" -c core.fsmonitor= rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        branch_icon=$(printf '\xee\x82\xa0')
        branch_part=" ${BLUE}${branch_icon} ${branch}${RESET}"
    fi
fi
echo "${context_part}${usage_part} | ${GREEN}${display_dir}${RESET}${branch_part}"
