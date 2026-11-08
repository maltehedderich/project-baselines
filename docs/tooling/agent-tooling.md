# Tools for my agents

[Setup overview](README.md)

These tools give agents access to current documentation, web research, a browser, GitHub, and commit-message generation through commands I can also run myself.

## Node.js prerequisite

The Context7, Brave, Playwright, and OpenCommit CLI packages use Node.js. With [mise installed and activated](development.md#mise), install the current LTS release:

```sh
mise use --global node@lts
```

Open a new terminal, then check:

```sh
node --version
npm --version
```

The npm commands below follow the CLIs' installation instructions. Globally installed npm packages belong to the active Node installation; reinstall them when switching to a new Node installation.

## Context7 (`ctx7`)

Context7 gives agents current library documentation and examples. I use it for API syntax, configuration, and library-specific behavior so the agent has a source to check.

```sh
npm install -g ctx7
ctx7 --help
```

Resolve the library first:

```sh
ctx7 library "Next.js" "How to configure redirects"
```

Then pass the returned library ID to `ctx7 docs`. For example, if the result is `/vercel/next.js`:

```sh
ctx7 docs /vercel/next.js "How to configure redirects"
```

Use `ctx7 login` for authenticated access and higher limits. Keep each query focused on one concept.

Source: [Context7 CLI](https://www.npmjs.com/package/ctx7).

## Brave Search CLI (`bx`)

Brave covers web research beyond library docs: errors, issue discussions, releases, and current information. Its `context` command returns extracted page content with source URLs for the agent to read and cite.

```sh
npm install -g @brave/brave-search-cli
bx --help
```

Get an API key from the [Brave Search API dashboard](https://api-dashboard.search.brave.com/), then enter it at the interactive prompt:

```sh
bx config set-key
```

Search with:

```sh
bx context "Zed latest release notes" --max-tokens 2048
```

The `context` command needs a compatible API plan. Use the explicit subcommand so it is clear which kind of search the agent is running.

Source: [Brave Search CLI](https://github.com/brave/brave-search-cli).

## Playwright CLI (`playwright-cli`)

Playwright lets agents inspect and operate the rendered interface. Snapshots, clicks, and screenshots make it possible to check whether a change works in the browser.

```sh
npm install -g @playwright/cli@latest
playwright-cli --help
playwright-cli install-browser chrome
```

A small browser session:

```sh
playwright-cli -s=check open https://example.com
playwright-cli -s=check snapshot
playwright-cli -s=check screenshot
playwright-cli -s=check close
```

Use element references from a fresh snapshot for clicks and form input. Give independent browser tasks their own session name.

Source: [Playwright CLI](https://github.com/microsoft/playwright-cli).

## GitHub CLI (`gh`)

`gh` gives agents direct access to issues, pull requests, and CI results. It is useful for repository work that would otherwise require opening GitHub in a browser.

```sh
brew install gh
gh auth login
gh auth status
```

Inside a repository with a GitHub remote:

```sh
gh issue list
gh pr list
gh run list
```

Sources: [installation](https://formulae.brew.sh/formula/gh), [authentication](https://cli.github.com/manual/gh_auth_login).

## OpenCommit (`oco`)

OpenCommit drafts commit messages from staged changes. It saves the work of writing the first draft, while leaving the message available to review and edit before committing.

```sh
npm install -g opencommit
oco --help
```

Configure an AI provider and its API key using the [upstream setup instructions](https://github.com/di-sukharev/opencommit). The CLI accepts settings through `oco config set` and stores them in `~/.opencommit`.

Inside a Git repository, select the changes to include and generate a message:

```sh
git add -p
oco
```

`oco` asks for confirmation before creating the commit. Review or edit the proposed message at that prompt. It also offers to push by default; disable that prompt with:

```sh
oco config set OCO_GITPUSH=false
```

Source: [OpenCommit](https://github.com/di-sukharev/opencommit).
