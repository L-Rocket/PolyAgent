# AGENTS.md — PolyAgent bootstrap repository

This Git repository publishes the public PolyAgent overview and workspace bootstrap files. It is **not** the multi-repository workspace root. A new workspace keeps this checkout at `.bootstrap/polyagent/`; `scripts/init-workspace.sh` installs `workspace/root/AGENTS.md`, `workspace/root/Makefile`, and its supporting script at the parent workspace root.

## Editing this repository

- Keep the complete agent-facing workspace guide in `workspace/root/AGENTS.md`. This root-level file only explains how to maintain the bootstrap repository; do not use it as the installed workspace guide.
- Keep `README.md`, `workspace/README.md`, the bootstrap script, and the installed template paths consistent.
- Publish only information appropriate for a public repository. Private clone URLs, credentials, machine addresses, and local configuration belong outside this repository.
- Test bootstrap changes with a temporary workspace whose root has no `.git`. Confirm the installed files, repository checks, and skill symlinks.
- Child projects are independent Git repositories. Make code changes and run builds in the owning project, following its own `AGENTS.md`.
