#!/usr/bin/env bash
# SessionStart hook: pull the latest auto-memory from other machines before
# memory files are loaded into context. Never blocks session startup beyond
# a short timeout; failures (offline, no remote changes, etc.) are silent.
set -u

MEMORY_REPO="$HOME/.local/share/claude-memory"

if [ -d "$MEMORY_REPO/.git" ]; then
    timeout 8 git -C "$MEMORY_REPO" pull --quiet >/dev/null 2>&1
fi

exit 0
