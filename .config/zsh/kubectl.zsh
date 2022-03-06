if (( $+commands[kubectl] )) ; then
    if [[ -d "$HOME/.kube/config.d" ]] && [[ -n $(find "$HOME/.kube/config.d" -not -empty) ]] ; then
        export KUBECONFIG=$(for f in "$HOME"/.kube/config.d/* ; do echo -n "$f:" ; done)
    fi
    if [[ -d "$HOME/.krew/bin" ]]; then export PATH="$PATH:$HOME/.krew/bin" ; fi

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

