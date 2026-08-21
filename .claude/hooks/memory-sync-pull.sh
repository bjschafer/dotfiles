#!/usr/bin/env bash
# SessionStart hook: clone the memory repo if this machine doesn't have it,
# register the current project for cross-machine sync if it isn't already,
# then reconcile with the remote before memory files are read into context.
#
# Reconciliation itself lives in memory-sync.sh so session start, turn end
# and tool writes all go through exactly one code path.
# Never blocks session startup; all failures are logged, not fatal.
set -u

. "$HOME/.claude/hooks/memory-sync-lib.sh" 2>/dev/null || exit 0

INIT_SCRIPT="$HOME/.local/bin/claude-memory-init"

ensure_memory_repo() {
    mem_repo_ready && return 0
    [ -e "$MEMORY_REPO" ] && return 1

    mkdir -p "$(dirname "$MEMORY_REPO")"
    mem_timeout 60 git -c core.sshCommand='ssh -o BatchMode=yes -o ConnectTimeout=10' \
        clone --quiet "$MEMORY_REPO_URL" "$MEMORY_REPO" >/dev/null 2>&1 || {
        mem_log "clone failed from $MEMORY_REPO_URL"
        return 1
    }
    # Sane defaults for anyone driving this repo by hand as well.
    mem_git config pull.rebase true >/dev/null 2>&1
    mem_git config rebase.autoStash true >/dev/null 2>&1
    mem_log "cloned memory repo"
}

auto_register() {
    command -v jq >/dev/null 2>&1 || return 0
    [ -x "$INIT_SCRIPT" ] || return 0

    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 0

    # Never register the sync repo against itself.
    [ "$repo_root" = "$MEMORY_REPO" ] && return 0

    settings_file="$repo_root/.claude/settings.local.json"

    # Already configured (or explicitly set) -- never overwrite.
    if [ -f "$settings_file" ] && jq -e 'has("autoMemoryDirectory")' "$settings_file" >/dev/null 2>&1; then
        return 0
    fi

    mem_timeout 30 "$INIT_SCRIPT" "$repo_root" >/dev/null 2>&1
}

ensure_memory_repo
if mem_repo_ready; then
    # Keep these current even on repos cloned by the old script.
    mem_git config pull.rebase true >/dev/null 2>&1
    mem_git config rebase.autoStash true >/dev/null 2>&1
    auto_register
    bash "$HOME/.claude/hooks/memory-sync.sh" </dev/null >/dev/null 2>&1
fi

exit 0
