#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
source /etc/os-release
[[ $ID == ubuntu && $VERSION_ID == 24.04 && $(uname -m) == x86_64 ]] || { echo 'Requires Ubuntu 24.04 x86-64.' >&2; exit 1; }
if [[ ${1:-} == --dry-run ]]; then
  echo 'Would install locked tools and pinned plugins; merge user shell, prompt, history and mise settings; back up changed files and retire fnm hooks. No services or credentials change.'
  echo 'Requires: zsh git curl ca-certificates unzip build-essential jq. Login shell is changed separately after checks.'
  exit 0
fi
[[ $# == 0 ]] || { echo 'Usage: setup [--dry-run]' >&2; exit 1; }
for tool in zsh git curl unzip jq; do
  command -v "$tool" >/dev/null || { echo "Missing $tool. Install system prerequisites first." >&2; exit 1; }
done
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null; then curl -LsSf https://astral.sh/uv/0.13.7/install.sh | sh; fi
exec uv run --script scripts/setup.py
