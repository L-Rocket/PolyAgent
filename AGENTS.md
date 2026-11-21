# AGENTS.md — PolyAgent workspace

This repository is the workspace entry point for PolyAgent. The directories created by `scripts/init-workspace.sh` are **independent Git repositories**, each with its own history, dependencies, and release process. Work inside one child repository at a time; there is no workspace-wide build or lockfile.

## First steps

1. Read [workspace/README.md](workspace/README.md) and run `scripts/init-workspace.sh` from this repository's root.
2. Check the script's remote, branch, and skill-link report. Report any missing repository access to the user.
3. Before changing a child repository, read its `AGENTS.md` and README. For work spanning repositories, read the relevant requirement in `managed-agents-design/`.

## Boundaries

- The public repository list is in `workspace/repos.tsv`. Optional private or personal repositories belong in the ignored `workspace/repos.local.tsv`.
- `.agents/skills/` contains generated local symlinks. Do not commit those links or the child repositories to this repository.
- Never commit credentials, private keys, `.env` files, or machine-specific configuration.
- Product-facing copy uses **PolyAgent**. Keep established technical identifiers such as repository names and package paths unchanged unless a separate migration is planned.
- Shared contracts use pinned versions, not local filesystem imports. The `pi/` checkout is upstream reference source; platform builds consume published packages pinned by `agent-runtime`.
