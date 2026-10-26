# Shared body for modify_ scripts on JSON files an app also writes to.
#
# json_merge deep-merges the managed JSON (fd 3) over the current target file
# (stdin) and prints the result. Keys absent from the managed JSON belong to
# the app and pass through untouched. Arrays are replaced, not merged. Output
# keeps the app's key order and trailing-newline habit, so a file whose managed
# keys already match is byte-identical and never shows up as drift.
set -eu

json_merge() {
    cur=$(mktemp)
    managed=$(mktemp)
    trap 'rm -f "$cur" "$managed"' EXIT
    cat > "$cur"
    cat <&3 > "$managed"

    if ! command -v jq >/dev/null 2>&1; then
        # No jq yet: leave the app's file alone, or seed it with the managed keys.
        if [ -s "$cur" ]; then cat "$cur"; else cat "$managed"; fi
        return
    fi

    [ -s "$cur" ] || echo '{}' > "$cur"
    nl=
    [ "$(tail -c1 "$cur" | od -An -c | tr -d ' ')" = '\n' ] || nl=-j
    jq $nl --slurpfile m "$managed" '. * $m[0]' "$cur"
}
