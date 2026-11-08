#!/usr/bin/env bash
set -euo pipefail
for mode in -c -ic -lic; do
  zsh "$mode" 'for tool in mise node npm bun uv uvx rg starship atuin zoxide fzf ctx7 bx playwright-cli oco; do command -v "$tool" >/dev/null || exit 1; done'
done
[[ $(zsh -c 'printf ready') == ready ]]
for mode in -ic -lic; do
  zsh "$mode" '
    [[ $aliases[gl] == "git pull" && $aliases[gp] == "git push" && $aliases[gco] == "git checkout" ]] || exit 1
    (( $+functions[git_main_branch] && $+functions[z] )) || exit 1
    [[ $(bindkey "^R") == *atuin-search && $(bindkey "^I") == *fzf-tab-complete ]] || exit 1
    (( $+functions[_zsh_autosuggest_start] && $+functions[_zsh_highlight] )) || exit 1
  '
done
for file in "$HOME/.zshenv" "$HOME/.zshrc"; do zsh -n "$file"; done
for plugin in fzf-tab/fzf-tab.zsh zsh-autosuggestions/zsh-autosuggestions.zsh zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  test -f "$HOME/.local/share/dev-shell/plugins/$plugin"
done
echo 'Shell syntax, quiet startup, tool discovery, Git shortcuts, and terminal bindings passed.'
echo 'Verify terminal keys, remote clients, authentication, and a browser session separately.'
