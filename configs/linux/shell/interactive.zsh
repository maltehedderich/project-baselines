HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY HIST_IGNORE_DUPS HIST_FIND_NO_DUPS
bindkey -e
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no
source "$HOME/.local/share/dev-shell/plugins/fzf-tab/fzf-tab.zsh"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(starship init zsh)"
alias ll='ls -lah'
source "$HOME/.local/share/dev-shell/git.zsh"
# Preserve SDKMAN when this account already uses it.
if [[ -z ${SDKMAN_DIR:-} && -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
source "$HOME/.local/share/dev-shell/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOME/.local/share/dev-shell/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
