# My tooling and coding setup

| Guide | Tools |
| --- | --- |
| [Development tools](development.md) | mise, uv, Bun |
| [Agent tools](agent-tooling.md) | Context7, Brave Search CLI, Playwright CLI, GitHub CLI, OpenCommit |
| [Desktop apps](desktop-apps.md) | Zed, Herdr |
| [Terminal setup](terminal.md) | zsh, Starship, Atuin, zoxide, fuzzy completion, fonts, and shortcuts |

The commands target macOS with zsh. Install commands and upstream documentation were checked on 2026-11-08. The terminal guide records the shell configuration inspected that day.

## Start with Homebrew

[Homebrew](https://brew.sh/) installs the desktop apps and command-line tools used below. If it is missing, run:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the installer's printed next steps to add Homebrew to your shell, then open a new terminal and check:

```sh
brew --version
```

Each guide has its own install commands. Work through the sections you need; login steps are separate from package installation.
