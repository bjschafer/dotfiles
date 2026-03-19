# syntax highlighting and autosuggestions
system_type="$(osfamily)"
if [[ "$system_type" == 'arch' ]]; then
    syntax=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    suggestions=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    youshoulduse=/usr/share/zsh/plugins/zsh-you-should-use/you-should-use.plugin.zsh
elif [[ "$system_type" == 'debian' ]]; then
    syntax=/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    suggestions=/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ "$system_type" == 'darwin' ]]; then
    syntax="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    suggestions="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    youshoulduse="$(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh"
fi
source_if_exists "$syntax"
source_if_exists "$suggestions"
source_if_exists "$youshoulduse"

# zsh preexec $2 is the alias-expanded command, but YSU compares $2 against
# raw alias values. Chained aliases (e.g. l='ls -lah' + ls='eza') break
# because $2='eza -lah' never matches 'ls -lah'. Use $1 (typed) for matching.
if (( $+functions[_check_aliases] )); then
    functions[_check_aliases_orig]="$functions[_check_aliases]"
    _check_aliases() { _check_aliases_orig "$1" "$1"; }
    functions[_check_global_aliases_orig]="$functions[_check_global_aliases]"
    _check_global_aliases() { _check_global_aliases_orig "$1" "$1"; }
fi

YSU_MESSAGE_POSITION='after'
