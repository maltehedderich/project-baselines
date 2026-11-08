# Desktop apps

[Setup overview](README.md)

## Zed

I use Zed as my IDE. I love how fast it is, and it feels less bloated than VS Code does these days.

```sh
brew install --cask zed
open -a Zed
```

Source: [Zed Homebrew cask](https://formulae.brew.sh/cask/zed).

### Settings

[settings.json](../../configs/zed/settings.json) contains my reusable editor settings:

- One Light and Night Owl Dark themes, following the system appearance, with Material icons.
- Format on save, a 120-column guide, and visible indentation and type hints.
- Inline warnings, Git blame after 500 ms, and Git status in tabs.
- Account and collaboration controls hidden, telemetry disabled, and Codex and Claude agent entries retained.
- Conventional Commit instructions for generated commit messages.

The theme and icon extensions install automatically through `auto_install_extensions`. Remote hosts and project paths are left out. There is no custom Zed keymap in this setup.

From the directory containing `configs/`, copy the settings for a new setup:

```sh
mkdir -p ~/.config/zed
cp -i configs/zed/settings.json ~/.config/zed/settings.json
```

For an existing setup, merge the settings you want through `zed: open settings file` in the command palette. `cp -i` asks before replacing an existing file. Agent entries still need their own authentication.

Source: [Zed settings reference](https://zed.dev/docs/reference/all-settings).

## Herdr

I use Herdr for my coding agents. It is fast and works well with remote machines.

Install the desktop app using its [official installer](https://herdr.dev/download/):

```sh
curl -fsSL https://releases.herdr.dev/app/install.sh | sh
open -a Herdr
```

The macOS app download targets Apple silicon. The installer includes `herdr-core`, which owns the terminal sessions. The app stores its layout, keys, and themes under `~/.config/herdr-app/`.

For remote work, add the machine through Herdr's interface. The [Herdr guide](https://herdr.dev/guide/) covers the app. Herdr also has a separate TUI; the command above installs the desktop app used here.

### Settings and keybindings

[settings.json](../../configs/herdr-app/settings.json) keeps zoom at 100%, enables notification sounds, and leaves terminal colors unchanged with `minimum_contrast` set to `1`.

[keys.json](../../configs/herdr-app/keys.json) records the complete macOS shortcut map found in this setup. Some of the useful bindings are:

| Shortcut | Action |
| --- | --- |
| Cmd-D / Cmd-Shift-D | Split right / down. |
| Cmd-Option-arrow | Focus the pane in that direction. |
| Cmd-Option-Shift-arrow | Swap panes in that direction. |
| Cmd-Shift-Enter | Toggle pane zoom. |
| Cmd-[ / Cmd-] | Previous / next agent. |
| Cmd-Option-[ / Cmd-Option-] | Previous / next space. |
| Cmd-1…9 / Ctrl-1…9 | Select a tab / space. |
| Cmd-Shift-P | Open the command palette. |
| Ctrl-V in a terminal | Paste an image. |

The terminal bindings also map Option-arrow to word movement, Cmd-arrow to line start/end, and Cmd-Backspace to deleting back to the start of the line in the configured zsh shell.

From the directory containing `configs/`:

```sh
mkdir -p ~/.config/herdr-app
cp -i configs/herdr-app/settings.json ~/.config/herdr-app/settings.json
cp -i configs/herdr-app/keys.json ~/.config/herdr-app/keys.json
```

These files apply live. On an existing setup, merge the bindings and settings you want; replacing `keys.json` replaces the entire map. Herdr treats edited maps as user-owned, so new default shortcuts may need to be added after upgrades.

Herdr writes an explanation to `keys.error` or `settings.error` if it rejects a change. Its bundled `~/.config/herdr-app/AGENTS.md` documents the configuration format for the installed version. Layouts, mods, and running-session state are not needed for these settings.
