##############################
# environment                #
##############################
export LANG=en_US.UTF-8
export EDITOR=nvim
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
TIMEFMT=$'real\t%E\nuser\t%U\nsys\t%S'

##############################
# OS-specific setup          #
##############################
case "$(osfamily)" in
    darwin)
        eval "$(/opt/homebrew/bin/brew shellenv)"
        fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
        ;;
esac

##############################
# PATH                       #
##############################
test -d "${HOME}/.local/bin" && export PATH="${HOME}/.local/bin:$PATH"
test -d "${XDG_DATA_HOME}/go/bin" && export PATH="$PATH:${XDG_DATA_HOME}/go/bin"
test -d "${XDG_DATA_HOME}/dotnet/.dotnet/tools" && export PATH="$PATH:${XDG_DATA_HOME}/dotnet/.dotnet/tools"
test -d "${XDG_DATA_HOME}/cargo/bin" && export PATH="$PATH:${XDG_DATA_HOME}/cargo/bin"

# Replace volatile Homebrew Cellar paths in fpath with stable opt symlinks.
# Without this, `brew upgrade` removes old Cellar dirs and breaks autoloaded
# completion functions in already-running shells.
() {
    local dir
    local -a new_fpath=()
    for dir in $fpath; do
        if [[ "$dir" == /opt/homebrew/Cellar/* ]]; then
            local name="${dir#/opt/homebrew/Cellar/}"
            name="${name%%/*}"
            local rest="${dir#/opt/homebrew/Cellar/$name/*/}"
            new_fpath+=("/opt/homebrew/opt/$name/$rest")
        else
            new_fpath+=("$dir")
        fi
    done
    fpath=($new_fpath)
}

# dedupe path
typeset -U path cdpath fpath manpath
