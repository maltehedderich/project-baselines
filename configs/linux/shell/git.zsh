# Common Oh My Zsh Git shortcuts (standalone; no framework required).
# Source: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh
# Resolve the main branch for gcm, gswm, and grbm using Oh My Zsh's order.
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local remote ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify "$ref"; then
      echo "${ref:t}"
      return 0
    fi
  done
  for remote in origin upstream; do
    ref=$(command git rev-parse --abbrev-ref "$remote/HEAD" 2>/dev/null)
    if [[ $ref == $remote/* ]]; then
      echo "${ref#"$remote/"}"
      return 0
    fi
  done
  echo master
  return 1
}

# Status and staging.
alias g='git'
alias gst='git status'
alias gss='git status --short'
alias gsb='git status --short --branch'
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'

# Branches and switching.
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch)'
alias gsw='git switch'
alias gswc='git switch --create'
alias gswm='git switch $(git_main_branch)'

# Commits (gcmsg "message"; gc! amends; gcn! amends without editing).
alias gc='git commit --verbose'
alias gcmsg='git commit --message'
alias gca='git commit --verbose --all'
alias gcam='git commit --all --message'
alias gc!='git commit --verbose --amend'
alias gcn!='git commit --verbose --no-edit --amend'

# Diffs and history.
alias gd='git diff'
alias gdca='git diff --cached'
alias gds='git diff --staged'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gsh='git show'

# Remotes and syncing.
alias gcl='git clone --recurse-submodules'
alias grv='git remote --verbose'
alias gf='git fetch'
alias gfa='git fetch --all --tags --prune --jobs=10'
alias gl='git pull'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpf='git push --force-with-lease --force-if-includes'

# Merging and rebasing.
alias gm='git merge'
alias gma='git merge --abort'
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbm='git rebase $(git_main_branch)'

# Stashes, unstaging, and reflog.
alias gsta='git stash push'
alias gstu='gsta --include-untracked'
alias gstp='git stash pop'
alias gstaa='git stash apply'
alias gstl='git stash list'
alias gsts='git stash show --patch'
alias grst='git restore --staged'
alias grf='git reflog'
