#!/usr/bin/env bash
# Shared helpers for the cross-machine auto-memory sync hooks.
# Sourced by memory-sync-pull.sh (SessionStart) and memory-sync.sh
# (PostToolUse / Stop / SessionEnd). Portable across Linux and macOS:
# no flock, no GNU-only stat/date/sed, bash 3.2 safe (macOS ships 3.2).

MEMORY_REPO="${MEMORY_REPO:-$HOME/.local/share/claude-memory}"
MEMORY_REPO_URL="${MEMORY_REPO_URL:-git@gitlab.cmdcentral.xyz:bschafer/claude-memory.git}"
MEM_LOCK="$MEMORY_REPO.lock"
MEM_LOG="${MEM_LOG:-$HOME/.claude/hooks/memory-sync.log}"
MEM_STATUS="${MEM_STATUS:-$HOME/.claude/hooks/memory-sync.status}"
MEM_FETCH_STAMP="${MEM_FETCH_STAMP:-$HOME/.claude/hooks/.memory-sync-fetched}"
MEM_LOCK_STALE=300      # seconds before a held lock is assumed abandoned
MEM_FETCH_INTERVAL=900  # seconds between no-op background fetches

# Hooks inherit a minimal PATH in some launchers; make sure the usual
# install prefixes (incl. Homebrew on both Apple Silicon and Intel) are seen.
PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"
export PATH

# GNU coreutils `timeout` is not present on stock macOS. Homebrew coreutils
# installs it as `gtimeout`. Fall back to a pure-bash watchdog when neither
# exists -- the previous hooks called `timeout` unguarded, which on a stock
# Mac makes the whole git command a no-op (command not found).
MEM_TIMEOUT_BIN="$(command -v timeout 2>/dev/null || command -v gtimeout 2>/dev/null || true)"

mem_timeout() {
    _mt_secs="$1"; shift
    if [ -n "$MEM_TIMEOUT_BIN" ]; then
        "$MEM_TIMEOUT_BIN" "$_mt_secs" "$@"
        return $?
    fi
    "$@" &
    _mt_cmd=$!
    ( sleep "$_mt_secs"; kill -TERM "$_mt_cmd" 2>/dev/null ) >/dev/null 2>&1 &
    _mt_watch=$!
    wait "$_mt_cmd" 2>/dev/null
    _mt_rc=$?
    kill -TERM "$_mt_watch" 2>/dev/null
    wait "$_mt_watch" 2>/dev/null
    return $_mt_rc
}

# Never let a hook sit on an SSH prompt it cannot answer, and never let a
# dead network hang the turn. Applied per-invocation so the user's own
# ~/.ssh/config is otherwise untouched.
# Kept as an array as well as a function: `timeout` is an external binary and
# cannot execute a shell function, so anything wrapped in mem_timeout must
# expand the real argv via "${MEM_GIT_CMD[@]}".
MEM_GIT_CMD=(git -C "$MEMORY_REPO" -c "core.sshCommand=ssh -o BatchMode=yes -o ConnectTimeout=10")

mem_git() { "${MEM_GIT_CMD[@]}" "$@"; }

mem_now() { date +%s; }

mem_mtime() {
    stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null
}

mem_log() {
    printf '%s [%s] %s\n' "$(date +%Y-%m-%dT%H:%M:%S)" "$(mem_host)" "$*" >>"$MEM_LOG" 2>/dev/null
}

mem_host() { hostname -s 2>/dev/null || uname -n 2>/dev/null || echo unknown; }

# Status is what makes failures visible instead of silent. status-line.sh
# reads this file; empty/absent means healthy.
mem_set_status() {
    if [ -z "${1:-}" ]; then
        rm -f "$MEM_STATUS" 2>/dev/null
    else
        printf '%s' "$1" >"$MEM_STATUS" 2>/dev/null
    fi
}

# mkdir is atomic on every POSIX filesystem, so it works where flock does
# not (macOS has no flock binary). Same idiom already used in status-line.sh.
mem_lock() {
    _ml_tries="${1:-1}"
    if [ -d "$MEM_LOCK" ]; then
        _ml_mtime="$(mem_mtime "$MEM_LOCK")"
        if [ -n "$_ml_mtime" ] && [ $(( $(mem_now) - _ml_mtime )) -ge "$MEM_LOCK_STALE" ]; then
            mem_log "reaping stale lock"
            rmdir "$MEM_LOCK" 2>/dev/null
        fi
    fi
    while [ "$_ml_tries" -gt 0 ]; do
        mkdir "$MEM_LOCK" 2>/dev/null && return 0
        _ml_tries=$(( _ml_tries - 1 ))
        [ "$_ml_tries" -gt 0 ] && sleep 1
    done
    return 1
}

mem_unlock() { rmdir "$MEM_LOCK" 2>/dev/null; }

mem_repo_ready() { [ -d "$MEMORY_REPO/.git" ]; }

# A rebase/merge left half-finished by a killed hook must never be pushed
# through or "fixed" automatically -- bail loudly and let the human look.
mem_in_progress() {
    _mp_dir="$(mem_git rev-parse --git-dir 2>/dev/null)" || return 1
    case "$_mp_dir" in /*) ;; *) _mp_dir="$MEMORY_REPO/$_mp_dir" ;; esac
    [ -d "$_mp_dir/rebase-merge" ] || [ -d "$_mp_dir/rebase-apply" ] || [ -f "$_mp_dir/MERGE_HEAD" ]
}

mem_branch() { mem_git symbolic-ref --quiet --short HEAD 2>/dev/null; }
