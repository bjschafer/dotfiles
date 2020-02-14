if [ -f "$HOME/.dotfiles/.profile" ]; then
    source "$HOME/.dotfiles/.profile"
    git -C "$HOME/.dotfiles" submodule init --update --recursive
fi
