#!/usr/bin/env bash

set -eo pipefail

if [ "${HELM_DEBUG:-}" = "1" ] || [ "${HELM_DEBUG:-}" = "true" ] || [ -n "${HELM_SECRETS_DEBUG+x}" ]; then
    set -eox pipefail
fi

HELM_BIN="${HELM_SECRETS_HELM_PATH:-"${HELM_BIN:-helm}"}"

# Color codes
NC='\e[0m'
RED='\e[0;31m'
BLUE='\e[0;34m'
GREEN='\e[0;32m'
YELLOW='\e[0;33m'

usage() {
    cat <<EOF
Masks kubernetes Secrets data in helm dry-run

This plugin provides ability to mask Secrets data which otherwise is visible
as base64 encoded text in helm dry-run.

🧾 Usage:
    ⎈ helm mask upgrade [RELEASE] [CHART] --dry-run [flags]                 Upgrade a helm chart
    ⎈ helm mask install [RELEASE] [CHART] --dry-run [flags]                 Install a helm chart
    ⎈ helm mask upgrade --install [RELEASE] [CHART] --dry-run [flags]       Install/Upgrade a helm chart
    ⎈ helm mask template [CHART] [flags]                                    Template a helm chart

EOF
}

prerequisite() {
    cat <<EOF

🚀 Below tools are prerequisites for using this helm plugin:
    ⎈ yq - https://github.com/mikefarah/yq/releases/
    ⎈ awk/gawk
    ⎈ helm3 - https://helm.sh/docs/intro/install/

EOF
}

missing_args() {
   echo -e ${RED}"Missing arguments!"${NC}
   echo -e ${BLUE}"---"${NC}
   usage
   exit 1
}

missing_prereq() {
   echo -e ${RED}"Missing pre-requisites!"${NC}
   echo -e ${BLUE}"---"${NC}
   prerequisite
   exit 1
}

status_check() {
    return_value=$?
    if [[ $return_value != 0 ]];then
        exit $return_value
    fi
}

mask() {
    $HELM_BIN $@ | sed -n '/NOTES:/q;p' | awk '/---/,EOF { print $0 }' | yq '( select(.kind == "Secret" and .data|length > 0 or .stringData|length > 0) | (.data[]?, .stringData[]?) ) = "(MASKED)"' && status_check || status_check 
}

main() {
    if [[ -z $(which awk) ]] || [[ -z $(which yq) ]] || [[ -z $(which helm) ]]; then
        missing_prereq
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
            missing_args
        fi


        if [[ $1 == "upgrade" ]] ||
            [[ $1 == "install" ]] && [[ "$@" == *"--dry-run"* ]]; then
            if [[ $# -lt 4 ]]; then
                missing_args
            else
                mask $@
            fi
        elif [[ $1 == "template" ]] || [[ "$@" == *"--dry-run"* ]]; then
            mask $@
        else
            missing_args
        fi

    fi

    exit 0

}

main $@