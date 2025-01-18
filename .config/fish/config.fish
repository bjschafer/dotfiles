fish_add_path --path $HOME/.cargo/bin
fish_add_path --path $HOME/.krew/bin
fish_add_path --path $HOME/.local/bin
fish_add_path --path $HOME/go/bin

if status is-interactive
    if not set -q TMUX
        and not set -q VIM
        exec tmux a || tmux
    end

    # Commands to run in interactive sessions can go here
    starship init fish | source

    if type -q fzf
        fzf --fish | source
    end

    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end

    if type -q zoxide
        zoxide init fish | source
    end

    set -g fish_key_bindings fish_vi_key_bindings

    bind --mode command vv '\ev'
    bind --mode insert enter expand-abbr execute # makes abbrs like !$ expand on enter
end
