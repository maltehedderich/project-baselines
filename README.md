# Project Baselines

The configurations, guidelines, and files I start new projects from. When a baseline changes here, I copy the update into the projects that use it.

## Contents

| File | What it is |
| --- | --- |
| [`.specify/memory/constitution.md`](.specify/memory/constitution.md) | Shared engineering constitution: rules for scope, architecture, contracts, security, testing, and delivery. |

## Adopt the constitution

Copy it to the same path in your project. [Spec Kit](https://github.com/github/spec-kit) reads it from there.

```sh
mkdir -p ../my-project/.specify/memory
cp .specify/memory/constitution.md ../my-project/.specify/memory/
```

Then record the version you adopted. Project-specific rules go in a Project Addendum section at the end of the copied file. Rules there can be stricter than the shared ones; weakening a shared MUST needs a recorded exception.

## Change a baseline

Every project that copies a file inherits its changes, so keep baselines free of project-specific names and paths. Constitution changes follow its Governance section: state the rationale and impact, and bump the version (MAJOR for incompatible changes, MINOR for new or expanded obligations, PATCH for clarifications).

## License

[MIT](LICENSE)
