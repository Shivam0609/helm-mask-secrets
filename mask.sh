#!/usr/bin/env bash

set -eo pipefail

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

Flags:
  -n, --namespace string                 Username for authenticated repo (assumes anonymous access if unspecified)
  -p, --password string                 Password for authenticated repo (prompts if unspecified and -u specified)

Username and Password for authenticated repo can be supplied using NEXUS_USERNAME and NEXUS_PASSWORD environment variables.
EOF
}

# declare NEXUS_USERNAME
# declare NEXUS_PASSWORD

declare -a POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
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

# indent() { sed 's/^/  /'; }

# declare HELM3_VERSION="$(helm version --client --short | grep "v3\.")"

# declare REPO=$1
# declare REPO_URL="$(helm repo list | grep "^$REPO" | awk '{print $2}')/"

# if [[ -n $HELM3_VERSION ]]; then
# declare REPO_AUTH_FILE="$HOME/.config/helm/auth.$REPO"
# else
# declare REPO_AUTH_FILE="$(helm home)/repository/auth.$REPO"
# fi

# if [[ $REPO_URL == / ]]; then
#     echo "Invalid repo specified!  Must specify one of these repos..."
#     helm repo list
#     echo "---"
#     usage
#     exit 1
# fi

# declare CMD
# declare AUTH
# declare CHART

# case "$2" in
# login)
#     if [[ -z "${NEXUS_USERNAME:-}" ]]; then
#         read -p "Username: " NEXUS_USERNAME
#     fi
#     if [[ -z "${NEXUS_PASSWORD:-}" ]]; then
#         read -s -p "Password: " NEXUS_PASSWORD
#         echo
#     fi
#     echo "$NEXUS_USERNAME:$NEXUS_PASSWORD" >"$REPO_AUTH_FILE"
#     ;;
# logout)
#     rm -f "$REPO_AUTH_FILE"
#     ;;
# *)
#     CMD=push
#     CHART=$2

#     if [[ -z "${NEXUS_USERNAME:-}" ]] || [[ -z "${NEXUS_PASSWORD:-}" ]]; then
#         if [[ -f "$REPO_AUTH_FILE" ]]; then
#             echo "Using cached login creds..."
#             AUTH="$(cat $REPO_AUTH_FILE)"
#         else
#             if [[ -z "${NEXUS_USERNAME:-}" ]]; then
#                 read -p "Username: " NEXUS_USERNAME
#             fi
#             if [[ -z "${NEXUS_PASSWORD:-}" ]]; then
#                 read -s -p "Password: " NEXUS_PASSWORD
#                 echo
#             fi
#             AUTH="$NEXUS_USERNAME:$NEXUS_PASSWORD"
#         fi
#     else
#         AUTH="$NEXUS_USERNAME:$NEXUS_PASSWORD"
#     fi

#     if [[ -d "$CHART" ]]; then
#         CHART_PACKAGE="$(helm package "$CHART" | cut -d":" -f2 | tr -d '[:space:]')"
#     else
#         CHART_PACKAGE="$CHART"
#     fi

#     echo "Pushing $CHART to repo $REPO_URL..."
#     curl --silent --fail --show-error -u "$AUTH" "$REPO_URL" --upload-file "$CHART_PACKAGE"
#     echo "Done"
#     ;;
# esac

exit 0