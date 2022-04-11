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
fi
source_if_exists "$syntax"
source_if_exists "$suggestions"
