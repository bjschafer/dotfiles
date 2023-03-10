# this file is purposefully not committed .bjs

export ZINC_SECRET_ACCESS_KEY='618567865be54af3a4af8b407812b6ce'

unalias kcuc
kcuc() {
    local current_context
    export KUBECONFIG=$(for f in "$HOME"/.kube/config.d/* ; do echo -n "$f:" ; done)
    kubectx "$@"

    current_context="$(kubectl config current-context)"
    if [[ "$current_context" = admin-* ]]; then
        export KUBECONFIG="$HOME/.kube/config.d/$current_context:$HOME/.kube/config.d/cfctl-${current_context#admin-}"
        kubectl config use-context "$current_context"
    else
        export KUBECONFIG="$HOME/.kube/config.d/$(kubectl config current-context)"
    fi
    "$HOME/.local/bin/cfctl" refresh
}
unalias kcn
kcn() {
    kubens "$@"
    "$HOME/.local/bin/cfctl" refresh
}

ksudo() {
  [[ $1 == "k" || $1 == "kubectl" ]] && shift

  kubectl --as=nobody --as-group=core-operators --as-group=system:authenticated "$@"
}

# when kubie spawns a subshell, it execs this. we want to attempt to auto-login when using normal contexts
#if grep -q kubie <<< "$KUBECONFIG" && grep -qvE '^admin-' <(kubectl config current-context) ; then
#    cfctl login "$(kubectl config current-context | sed 's/^cfctl-//')"
#fi

kadmin() {
  [[ $1 == "k" || $1 == "kubectl" ]] && shift
  local CONTEXT
  CONTEXT=$(kubectl config current-context)

  case ${CONTEXT}
  in
    cfctl-*)
      local CURRENT_NAMESPACE
      CURRENT_NAMESPACE=$(kubectl config get-contexts --no-headers "${CONTEXT}" | awk '{print $5}')
      # If the namespace is specified a second time, it will take precedent
      kubectl --context="${CONTEXT/cfctl/admin}" -n "${CURRENT_NAMESPACE}" "$@"
    ;;
    *)
      echo "This is not a cfctl-* context, cannot upgrade to admin context!" >&2
      return 1
    ;;
  esac
}

export PKG_CONFIG_PATH='/usr/local/lib/pkgconfig'

alias jumpStartPDX='ssh -fNT -D 1233 36.primary.cfops.net'
alias jumpStartLUX='ssh -fNT -D 1233 99.primary.cfops.net'

shellPod() {
    if [[ $# -ne 1 ]]
    then
        echo "Usage: shellPod <node>"
        return 1
    fi
    local POD_NAME
    POD_NAME=$(kubectl -n shell get pods -l app=shell -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName | grep "${1}" | awk '{print $1}')
    if [[ "$(echo "${POD_NAME}" | wc -w | tr -d '[:space:]')" != "1" ]]
    then
        echo "Ambiguous node name!"
        return 1
    fi
    kubectl --as=nobody --as-group=core-operators --as-group=system:authenticated -n shell exec -it "${POD_NAME}" -- bash
}

firmwareUpgradePending() {
  local LOOKBACK NODE
  NODE=$1
  LOOKBACK=$2

  if [[ ${NODE} == "" ]]
  then
    echo "Node short name must be provided!" >&2
    echo "Usage: $(basename "${0}") <node> [lookback]"
    return 1
  fi

  if [[ ${NODE} =~ .*\.cfops\.(it|net) ]]
  then
    echo "Must use node shortname!" >&2
    return 1
  fi

  if [[ ${LOOKBACK} == "" ]]
  then
    LOOKBACK="1H"
  fi

  local RESULT
  if ! RESULT=$(cloudflared access curl 'https://36dm8.prometheus-access.cfdata.org/api/v1/query_range' \
  --silent \
  --data-urlencode "query=fua_nextboot_upgrade{instance=\"${NODE}\"}" \
  --data-urlencode "start=$(date -v "-${LOOKBACK}" -u "+%s")" \
  --data-urlencode "end=$(date "+%s")" \
  --data-urlencode "step=1m" \
  | jq -r '.data.result[]')
  then
    echo "Metric lookup failed!" >&2
    return 1
  fi

  if [[ ${RESULT} == "" ]]
  then
    echo "No firmware upgrade pending for ${NODE}"
    return 0
  else
    local LATEST
    LATEST=$(jq -r '.values[] | select(.[1] == "1") | .[0]'  <<< "${RESULT}" | sort -u | xargs -n1 date -r | tail -n 1)
    echo "${NODE} last had a firmware upgrade pending at ${LATEST}"
    return 0
  fi
}
