
![banner](resources/banner.png)

# Mask - Helm Plugin


## About

A helm plugin that provides ability to mask secrets data,
which otherwise is visible as base64 encoded text in helm dry-run.

# Getting Started 🚀

## Prerequisites

  * `yq` - https://github.com/mikefarah/yq/releases/
  * `awk/gawk`
  * `helm3` - https://helm.sh/docs/intro/install/

## Installation

  * `helm plugin install --version main https://github.com/Shivam0609/helm-mask-secrets.git`
  * `chmod +x /root/.local/share/helm/plugins/helm-mask-secrets.git/mask.sh`
  * `helm mask --help`

## Usage

  * `helm mask upgrade [RELEASE] [CHART] --dry-run [flags]`
  * `helm mask install [RELEASE] [CHART] --dry-run [flags]`
  * `helm mask upgrade --install [RELEASE] [CHART] --dry-run [flags]`
  * `helm mask template [CHART] [flags]`

## Uninstall

  * `helm plugin uninstall mask`


Additional help available `helm mask --help`

## Need help

Looking to contribute to our code but need some help?

* Log an issue here on GitHub
