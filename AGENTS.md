# AGENTS.md

This repository holds baseline files that other projects copy: configurations, guidelines, and agent instructions. It has no application code, build, or test suite.

## Layout

- `.specify/memory/constitution.md` is the shared engineering constitution. It sits at the path Spec Kit uses in target projects.

## Editing baselines

- Baseline files get copied into other repositories. They MUST NOT mention this repository, its paths, or details of a specific project.
- Constitution changes follow its Governance section: state the rationale and impact, update the version line semantically, and update the Last Amended date.
- Most files here are prose. Use plain words and short sentences, use RFC 2119 keywords only for normative rules, and cut anything that does not change what a reader does.

## Checks

Run `git diff --check` before finishing to catch trailing whitespace and conflict markers. There are no other automated checks yet, so reread changed Markdown and confirm relative links resolve.
