# Development tools

[Setup overview](README.md)

mise manages the project environment. uv handles Python dependencies and execution; Bun handles JavaScript and TypeScript. This gives each tool a clear job.

## mise

The appeal is having tool versions, tasks, and environment configuration in one place. A project's `mise.toml` tells me how to work on it, and the same task names can carry across projects.

Install with [Homebrew](https://mise.jdx.dev/installing-mise.html):

```sh
brew install mise
mise --version
```

Add this line once to `~/.zshrc`, after Homebrew is on `PATH`:

```zsh
eval "$(mise activate zsh)"
```

Open a new terminal. For a project with a reviewed mise configuration:

```sh
mise trust
mise install
mise tasks ls
```

Run the tasks the project defines with `mise run <task>`. Project tool versions override global defaults. See [shell setup](https://mise.jdx.dev/shell-setup.html) and [getting started](https://mise.jdx.dev/getting-started.html).

## uv

uv puts Python dependencies, virtual environments, and script execution behind one command. `uv run` prepares the project environment before running a command, so there is no separate activation step to remember.

Install the machine-wide command:

```sh
brew install uv
uv --version
```

Try it in a new directory:

```sh
uv init python-example
cd python-example
uv run main.py
```

In an existing project, use `uv sync` to install its dependencies, `uv add <package>` to add one, and `uv run <command>` to run inside its environment. `uvx` runs standalone Python tools.

Sources: [installation](https://docs.astral.sh/uv/getting-started/installation/), [project workflow](https://docs.astral.sh/uv/guides/projects/).

## Bun

Bun brings dependency installation, JavaScript and TypeScript execution, and testing into one tool. It keeps the everyday commands short.

Install the machine-wide command:

```sh
brew install bun
bun --version
```

In an existing JavaScript or TypeScript project:

```sh
bun install
```

Use `bun add <package>` to add a dependency. Where a project defines mise tasks, use those tasks as its normal entry point.

Homebrew provides the initial uv and Bun commands. Projects can declare their own versions in mise; those take precedence when mise is active.

Sources: [Homebrew package](https://formulae.brew.sh/formula/bun), [Bun package installation](https://bun.sh/docs/pm/cli/install).
