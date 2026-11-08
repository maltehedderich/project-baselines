# Terminal setup

[Setup overview](README.md)

The shell setup is zsh with individual plugins and a Starship prompt. Git shortcuts are defined directly in the shell configuration. There is no Oh My Zsh framework to load.

The example below includes a small set of Git shortcuts. The [complete alias file](../../configs/linux/shell/git.zsh) records the Mac's full set, including `gl` for `git pull` and `gp` for `git push`. The Linux bootstrap installs that full set.

## What each part does

| Tool | Benefit in this setup |
| --- | --- |
| [Starship](https://starship.rs/) | Shows the directory, Git branch and status, and the duration of commands that take at least two seconds. |
| [Atuin](https://atuin.sh/) | Searches shell history with Ctrl-R. The up arrow keeps its normal shell behavior. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Jumps to frequently used directories with `z`. |
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) and [fzf](https://junegunn.github.io/fzf/) | Make completion candidates searchable when pressing Tab. |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Suggests commands from shell history as I type. |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colors the command line while I edit it. |
| [FiraCode Nerd Font](https://formulae.brew.sh/cask/font-fira-code-nerd-font) | Provides the monospace font and symbols used by the prompt. |

## Install

macOS includes zsh. Install the extra tools with Homebrew:

```sh
brew install starship atuin zoxide fzf fzf-tab \
  zsh-autosuggestions zsh-syntax-highlighting
brew install --cask font-fira-code-nerd-font
```

## Shell configuration

Merge this into `~/.zshrc`. Keep one completion initialization, load fzf-tab before autosuggestions, and keep syntax highlighting last. The block captures the reusable parts of the inspected configuration; it leaves machine-specific functions and credentials out.

```zsh
# Support shells opened by editors without a Homebrew environment.
if [[ -z ${HOMEBREW_PREFIX:-} ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

typeset -U path fpath
path=("$HOME/.local/bin" "$HOME/.bun/bin" $path)
fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY INC_APPEND_HISTORY EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS HIST_FIND_NO_DUPS
bindkey -e

mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no

source "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(starship init zsh)"

alias ll='ls -lah'
alias gst='git status'
alias ga='git add'
alias gcmsg='git commit --message'
alias gd='git diff'
alias gdca='git diff --cached'
alias glog='git log --oneline --decorate --graph'
alias gl='git pull'
alias gp='git push'
alias gco='git checkout'

source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
```

Add [mise activation](development.md#mise) before the final two plugin lines if using mise. Open a new terminal after saving.

The inspected machine also has an fnm hook for Node.js and a direnv hook for directory-specific environments. Those are existing setup details. When moving a shell to mise, remove the fnm hook once mise owns its Node installation, and review existing `.envrc` files before removing direnv. For a shell that still needs direnv:

```sh
brew install direnv
```

Its existing hook is `eval "$(direnv hook zsh)"`, placed before the final plugin lines. See [direnv's shell setup](https://direnv.net/docs/hook.html).

## Prompt

Create `~/.config` if needed:

```sh
mkdir -p ~/.config
```

Save the following as `~/.config/starship.toml`. It reproduces the inspected prompt: directory and Git information on the first line, duration on the right, and a green or red prompt character below.

```toml
add_newline = false

format = """
$directory\
$git_branch\
$git_status\
$fill\
$cmd_duration\
$line_break\
$character"""

[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold blue"

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "
style = "bold purple"

[git_status]
format = "[$all_status$ahead_behind]($style)"
style = "yellow"

[fill]
symbol = " "

[cmd_duration]
min_time = 2000
format = "[$duration]($style)"
style = "dimmed white"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
```

## Appearance and terminal apps

[Herdr](desktop-apps.md#herdr) is the installed app used for agents. Its settings and layouts live under `~/.config/herdr-app/`.

Choose the font and appearance in Herdr's settings or layout.

## Everyday keys

| Key or command | Action |
| --- | --- |
| Ctrl-R | Search Atuin history. The inspected config has `enter_accept = true`, so Enter runs the selected command. |
| Up arrow | Use normal zsh history navigation. |
| Tab | Open fuzzy completion. |
| Right arrow at the end of the line | Accept an autosuggestion. |
| Ctrl-A / Ctrl-E | Move to the start or end of the command. |
| `z <directory-name>` | Jump to a directory zoxide has learned. |

Atuin's Enter behavior can be set explicitly in `~/.config/atuin/config.toml` with `enter_accept = true`. No history-sync account is required for local history search.
