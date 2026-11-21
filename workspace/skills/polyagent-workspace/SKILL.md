---
name: polyagent-workspace
description: Initialize and inspect the PolyAgent multi-repository workspace, including child repository checkouts and local skill symlinks.
---

# PolyAgent workspace

Read the workspace root `AGENTS.md` and `workspace/README.md`, then run `scripts/init-workspace.sh` from the root. Report each failed or inaccessible repository. Before working in a child repository, read its own `AGENTS.md` and README. Never commit child repositories, local skill links, or credentials to the PolyAgent entry-point repository.
