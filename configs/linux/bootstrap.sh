#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
# Dry-run needs neither mise, uv, nor a trusted config.
if [[ ${1:-} == --dry-run ]]; then exec bash scripts/setup.sh --dry-run; fi
source /etc/os-release
[[ $ID == ubuntu && $VERSION_ID == 24.04 && $(uname -m) == x86_64 ]] || { echo 'Requires Ubuntu 24.04 x86-64.' >&2; exit 1; }
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null; then
  curl -fsSL https://mise.run | MISE_VERSION=2026.11.2 sh
fi
mise trust "$PWD/mise.toml"
exec mise run setup "$@"
