---
name: polyagent-workspace
description: Initialize and inspect the PolyAgent multi-repository workspace, including child repository checkouts and local skill symlinks.
---

# PolyAgent workspace

Read the workspace root `AGENTS.md` and `.bootstrap/polyagent/workspace/README.md`, then run `.bootstrap/polyagent/scripts/init-workspace.sh` from the root. Report each failed or inaccessible repository. Before working in a child repository, read its own `AGENTS.md` and README. Keep the workspace root outside Git; never commit credentials or local configuration to the bootstrap repository.
