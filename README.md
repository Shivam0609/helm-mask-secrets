# Helm Mask Secrets Plugin

A Helm plugin that provides ability to mask Secrets data which otherwise is visible as base64
encoded text in helm dry-run.

## Installation

  * `helm plugin install --version main https://github.com/Shivam0609/helm-mask-secrets.git`
  * `helm mask-secrets --help`

## Updates

  * `cd $HELM_HOME/plugins/mask-secrets`
  * `git pull`

## Usage

  * `helm mask-secrets upgrade --dry-run [flags]`
  * `helm mask-secrets upgrade --install release chart --dry-run [flags]`
  * `helm mask-secrets template chart [flags]`

Additional help available `helm mask-secrets --help`

## Getting help

Looking to contribute to our code but need some help?

* Log an issue here on GitHub