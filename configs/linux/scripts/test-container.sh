#!/usr/bin/env bash
# Run inside a disposable Ubuntu 24.04 container with this bundle at /bundle.
set -euo pipefail
[[ -f /.dockerenv && -d /bundle ]] || { echo 'Run only in a disposable Docker container with the bundle mounted at /bundle.' >&2; exit 1; }
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh git curl ca-certificates unzip build-essential jq >/dev/null
useradd -m -s /bin/bash developer
cp -a /bundle /home/developer/setup
chown -R developer:developer /home/developer/setup
# Seed existing configuration and the recognized legacy runtime hook.
su developer -c 'mkdir -p ~/.config/mise; printf "[env]\nKEEP_ME = \"yes\"\n" > ~/.config/mise/config.toml'
cat >> /home/developer/.bashrc <<'LEGACY'
# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
alias keep_me='echo preserved'
LEGACY
su developer -c 'find ~ -type f -exec sha256sum {} + | sort > /tmp/dry-before'
su developer -c 'cd ~/setup && bash bootstrap.sh --dry-run'
su developer -c 'find ~ -type f -exec sha256sum {} + | sort > /tmp/dry-after'
diff -u /tmp/dry-before /tmp/dry-after
su developer -c 'cd ~/setup && bash bootstrap.sh'
su developer -c 'cd ~/setup && PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH" mise run check'
su developer -c 'find ~/.config ~/.playwright ~/.zshenv ~/.zshrc ~/.bashrc ~/.profile -type f -exec sha256sum {} + | sort > /tmp/config-before'
su developer -c 'cd ~/setup && PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH" mise run setup'
su developer -c 'find ~/.config ~/.playwright ~/.zshenv ~/.zshrc ~/.bashrc ~/.profile -type f -exec sha256sum {} + | sort > /tmp/config-after'
diff -u /tmp/config-before /tmp/config-after
su developer -c 'grep -q KEEP_ME ~/.config/mise/config.toml; grep -q keep_me ~/.bashrc; ! grep -q "fnm env" ~/.bashrc'
su developer -c 'test -n "$(find ~/.local/state/dev-shell/backups -name .bashrc -print)"'
echo 'Fresh installation, legacy-hook migration, config preservation, and repeat-run checks passed.'
