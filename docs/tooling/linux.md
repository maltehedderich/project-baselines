# Linux development host

[Setup overview](README.md)

Herdr and Zed run on the Mac. The Linux host runs project tools, agent CLIs,
headless browsers, Herdr core, and Zed's remote server. Install the Nerd Font on
the Mac, where terminal text is rendered.

The [Linux bundle](../../configs/linux/) supports Ubuntu 24.04 on x86-64.
Copy the whole directory to the host. It configures the account that runs it;
run it as your normal user.

## Install

Install system prerequisites once:

```sh
sudo apt-get update
sudo apt-get install -y zsh git curl ca-certificates unzip build-essential jq
```

From the copied Linux bundle, review the changes and install:

```sh
bash bootstrap.sh --dry-run
bash bootstrap.sh
mise run check
```

The bootstrap installs mise and uv if absent. Tool releases are pinned in
`tools/mise.toml`, with download checksums and npm dependency resolutions in
`tools/mise.lock` and its companion files in `tools/.mise/locks/`. Keep these
hidden directories when copying the bundle. Zsh plugins use fixed Git revisions. Existing mise and uv
commands are reused for bootstrapping.

The setup merges global mise defaults and shell configuration. Project mise
files retain precedence. Node `.node-version` files remain supported for
projects that have not moved their runtime declarations to mise. The initial
global Node version is 22.16.0; upgrade it deliberately with the manifest and
lockfile rather than during a shell migration.

After the checks pass, change the login shell:

```sh
chsh -s /usr/bin/zsh
```

Open a new SSH connection and new terminals in Herdr and Zed. Existing sessions
keep their existing shell and environment.

## Everyday behavior

The shell matches the [terminal guide](terminal.md): Ctrl-R searches local Atuin
history, Enter executes the selected entry, Up retains normal history behavior,
Tab uses fuzzy completion, and `z` jumps to learned directories. The prompt also
shows the host name. Atuin sync and update checks are disabled. Existing Bash
history remains available in its original file.

The [Git shortcuts](../../configs/linux/shell/git.zsh) match the Mac's full
standalone alias set, including `gl` (pull), `gp` (push), `gco` (checkout), and
`gcm` (checkout the main branch). They do not require Oh My Zsh.

Mise manages Node, Bun, uv, ripgrep, Starship, Atuin, zoxide, fzf, Context7,
Brave Search CLI, Playwright CLI, and OpenCommit. Codex, Claude, GitHub CLI,
Herdr core, and Zed's remote server keep their existing installation methods.
See [agent tools](agent-tooling.md) for authentication. A fresh host needs those
separate tools installed and authenticated before agent workflows can work.

The installer retires the recognized fnm block and moves conflicting binaries
and links from `~/.local/bin` into a backup. An unfamiliar fnm hook stops the
migration for review. SDKMAN configuration is retained. Go installations under
`/usr/local/go/bin` and `~/go/bin` stay on PATH when present.

## Remote checks

`mise run check` checks tool discovery in noninteractive, interactive, and login
zsh shells, quiet command startup, shell syntax, Git shortcuts, and terminal
bindings. Also check:

- Start Codex and Claude in new Herdr terminals and reconnect the Mac client.
- Open a remote project in Zed and verify its terminal and language tools.
- Run the project's existing checks with its own mise configuration.
- Exercise Ctrl-R, Tab, suggestions, prompt symbols, and navigation from the Mac.
- Run a named, headless Playwright session, take a screenshot, and close it.
  The bootstrap configures the CLI's global browser as Chromium using the
  `chrome-for-testing` channel. Install its browser and Linux dependencies if
  missing. Browser downloads are separate from the shell bootstrap.

Keep development servers bound to loopback. For example, forward a server
listening on remote port 3000 from the Mac:

```sh
ssh -N -L 3000:127.0.0.1:3000 <ssh-host>
```

Open `http://localhost:3000` on the Mac. Herdr owns its remote sessions; this
setup does not automatically nest them inside tmux. A host reboot does not
resume the original agent process.

## Rerun, update, and restore

From the bundle, run `mise run setup --dry-run`, `mise run setup`, or
`mise run check`. Repeated setup keeps unrelated configuration and does not
change services, credentials, firewall rules, or project files.

For an update, change the reviewed versions in `tools/mise.toml`, regenerate
its lock with `mise -C tools lock`, test, and rerun setup. Update plugin revisions
in `scripts/setup.py` separately. Do not delete the lockfile to refresh tools.

Changed files and displaced executable links are backed up under
`~/.local/state/dev-shell/backups/<timestamp>/`, preserving paths relative to
your home directory. Restore the files from the migration's backup, including
`.bashrc`, `.profile`, and the displaced binaries. Remove managed blocks from
new `.zshenv` and `.zshrc` files if no originals existed. Restore the old global
mise configuration, or remove the added entries if that file was new. Restore
the previous login shell with `chsh -s /bin/bash`, then reconnect. Installed tool
versions and plugin downloads can remain until the restored shell is verified.

For isolated testing, mount the bundle at `/bundle` in a disposable Ubuntu
24.04 container and run `bash /bundle/scripts/test-container.sh`. The test
installs into an unprivileged account, runs shell checks, and compares config
hashes across two setup runs. Do not run that container test on the host itself.

References: [mise shell setup](https://mise.jdx.dev/shell-setup.html),
[mise shims](https://mise.jdx.dev/dev-tools/shims.html), and
[mise npm tools](https://mise.jdx.dev/lang/node.html).
