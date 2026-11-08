# Quiet startup for SSH commands, editor tasks, scripts, and interactive shells.
typeset -U path
path=("$HOME/.local/share/mise/shims" "$HOME/.local/bin" $path)
[[ ! -d /usr/local/go/bin ]] || path+=(/usr/local/go/bin)
[[ ! -d "$HOME/go/bin" ]] || path+=("$HOME/go/bin")
export PATH
