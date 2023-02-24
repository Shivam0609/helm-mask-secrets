#!/usr/bin/env bash

set -euf

if [ "${HELM_DEBUG:-}" = "1" ] || [ "${HELM_DEBUG:-}" = "true" ] || [ -n "${HELM_SECRETS_DEBUG+x}" ]; then
    set -x
fi

usage() {
    cat <<EOF
Masks kubernetes Secrets data in helm dry-run

This plugin provides ability to mask Secrets data which otherwise is visible as base64
encoded text in helm dry-run.

Usage:
  helm mask-secrets upgrade --dry-run [flags]                               Upgrade a helm chart
  helm mask-secrets install release chart --dry-run [flags]                 Install a helm chart
  helm mask-secrets upgrade --install release chart --dry-run [flags]       Install/Upgrade a helm chart
  helm mask-secrets template chart [flags]                                  Template a helm chart

EOF
}

prerequite() {
    cat <<EOF
Below tools are pre-requisites for using this helm plugin, Please install them before running:
    * yq - https://github.com/mikefarah/yq/releases/
    * awk

EOF
}


if [[ -z $(which awk) ]] || [[ -z $(which yq) ]]; then
    echo "Missing pre-requisites!"
    echo "---"
    prerequite
    exit 1
else
    declare -a POSITIONAL_ARGS=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -h | --help | help)
            usage
            exit 0
            ;;

        *)
            POSITIONAL_ARGS+=("$1")
            ;;
        esac
        shift
    done
    [[ ${#POSITIONAL_ARGS[@]} -ne 0 ]] && set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

    if [[ $# -lt 2 ]]; then
        echo "Missing arguments!"
        echo "---"
        usage
        exit 1
    fi

    HELM_BIN="${HELM_SECRETS_HELM_PATH:-"${HELM_BIN:-helm}"}"


    if [[ $1 == "upgrade" ]] ||
        [[ $1 == "install" ]] && [[ "$@" == *"--dry-run"* ]]; then
        if [[ $# -lt 4 ]]; then
            echo "Missing arguments!"
            echo "---"
            usage
            exit 1
        else
            $HELM_BIN $@ | sed -n '/NOTES:/q;p' | awk '/---/,EOF { print $0 }' | yq -M '( select(.kind == "Secret" and .data|length > 0 or .stringData|length > 0) | (.data[]?, .stringData[]?) ) = "(MASKED)"'
        fi
    elif [[ $1 == "template" ]] || [[ "$@" == *"--dry-run"* ]]; then
        $HELM_BIN $@ | sed -n '/NOTES:/q;p' | awk '/---/,EOF { print $0 }' | yq -M '( select(.kind == "Secret" and .data|length > 0 or .stringData|length > 0) | (.data[]?, .stringData[]?) ) = "(MASKED)"'
    else
        echo "Missing arguments!"
        echo "---"
        usage
        exit 1
    fi

fi

exit 0