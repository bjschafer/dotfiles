export_if_exists ANSIBLE_HOME "$XDG_DATA_HOME/ansible"
export_if_exists BUNDLE_USER_CONFIG "$XDG_CONFIG_HOME/bundle"
export_if_exists BUNDLE_USER_CACHE "$XDG_CACHE_HOME/bundle"
export_if_exists BUNDLE_USER_PLUGIN "$XDG_DATA_HOME/bundle"
export_xdg_home CARGO_HOME "$XDG_DATA_HOME/cargo"
export_xdg_home DOTNET_CLI_HOME "$XDG_DATA_HOME/dotnet"
export_if_exists GNUPGHOME "$XDG_DATA_HOME/gnupg"
export_xdg_home GOPATH "$XDG_DATA_HOME/go"
export_if_exists NUGET_PACKAGES "$XDG_CACHE_HOME/NuGetPackages"
export_if_exists OMNISHARPHOME "$XDG_CONFIG_HOME/omnisharp"
export_xdg_home RUSTUP_HOME "$XDG_DATA_HOME/rustup"
export_if_exists SCREENRC "$XDG_CONFIG_HOME/screen/screenrc"
# Ghostty and kitty ship their terminfo inside the app bundle and point
# TERMINFO at it. Capture that before repointing TERMINFO at the XDG dir
# (where `tic` installs), and keep it searchable via TERMINFO_DIRS below —
# otherwise TERM=xterm-ghostty / xterm-kitty becomes an unknown terminal.
inherited_terminfo="${TERMINFO-}"
export_if_exists TERMINFO "$XDG_DATA_HOME/terminfo"

# TERMINFO_DIRS is a colon-separated list, so export_if_exists can't be used:
# it stats the whole value as one path, which never exists. Guard on the XDG
# directory instead. The /usr/share/terminfo entry has to stay explicit —
# setting TERMINFO_DIRS replaces the compiled-in search path rather than
# extending it, so dropping it would hide every system terminfo entry.
# Inherited entries are kept so nested shells (and tmux panes) still see the
# app-bundle dir after the outer shell has already repointed TERMINFO.
if [[ -d "$XDG_DATA_HOME/terminfo" ]]; then
    typeset -aU terminfo_search=(
        "$XDG_DATA_HOME/terminfo" /usr/share/terminfo
        ${(s.:.)TERMINFO_DIRS} $inherited_terminfo
    )
    export TERMINFO_DIRS="${(j.:.)terminfo_search}"
    unset terminfo_search
fi
unset inherited_terminfo

export_if_exists WINEPREFIX "$XDG_DATA_HOME/wine"

export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
