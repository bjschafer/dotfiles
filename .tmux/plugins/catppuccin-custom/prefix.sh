show_prefix() {
    local color # the entire background is this color
    local text

    color=$( get_tmux_option '@catppuccin_prefix_color' "$thm_yellow" )
    text=$(  get_tmux_option '@catppuccin_prefix_text'  '󰘴a')


    # left box character
    echo -n "#[fg=$color,bg=$thm_bg,nobold,nounderscore,noitalics]#{?client_prefix,$status_left_separator,}"

    # main
    echo -n "#[bg=$color,fg=$thm_bg]#{?client_prefix,${text},}"

    # right box character
    echo "#[fg=$color,bg=$thm_bg,nobold,nounderscore,noitalics]#{?client_prefix,$status_right_separator,}#[default]"

}
