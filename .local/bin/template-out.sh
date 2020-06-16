#!/usr/bin/env bash

set -euo pipefail

INPUTFILE="$1"
OUTPUTFILE="${1/\.tpl/}"

function get_params() {
  grep -Eo '\{\{\w+\}\}' "$INPUTFILE" | sed 's/[\{\}]//g' | sort | uniq
}

function ask_param_value() {
  local param="$1"

  read -r -p "Enter value for ${param}: " value

  echo "$value"
}

ALLPARAMS="$(get_params)"

for param in $ALLPARAMS ; do
  eval "export $param=$(ask_param_value "$param")"
done

mo "$INPUTFILE" > "$OUTPUTFILE"

for param in $ALLPARAMS ; do
  eval "unset $param"
done
