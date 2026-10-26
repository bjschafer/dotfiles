if (( $+commands[kubectl] )) ; then
    if [[ -d "$HOME/.kube/config.d" ]] && [[ -n $(find "$HOME/.kube/config.d" -not -empty) ]] ; then
        export KUBECONFIG=$(for f in "$HOME"/.kube/config.d/* ; do echo -n "$f:" ; done)
    fi

    if [[ -d "$HOME/.local/share/krew"  ]]; then
        export KREW_ROOT="$HOME/.local/share/krew"
        export PATH="$PATH:$KREW_ROOT/bin"
    fi

    KUBE_PS1_PREFIX='['
    KUBE_PS1_SUFFIX=']'
    KUBE_PS1_SYMBOL_ENABLE=false

    function get_cluster_short() {
        cut -d'@' -f1 <<< "$1"
    }

    KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
else
    function kube_ps1() { }
fi

alias vks="jq -r '.data | to_entries | map(\"---\n\(.key):\n\(.value | @base64d)\n\") | .[]'"
