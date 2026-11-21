# Initialize a PolyAgent workspace

Create a workspace directory and clone [L-Rocket/PolyAgent](https://github.com/L-Rocket/PolyAgent) into its hidden `.bootstrap/polyagent/` child. The **workspace root is not a Git repository**; each project checkout has its own `.git`.

```bash
mkdir -p PolyAgent-workspace/.bootstrap
git clone https://github.com/L-Rocket/PolyAgent.git PolyAgent-workspace/.bootstrap/polyagent
cd PolyAgent-workspace
.bootstrap/polyagent/scripts/init-workspace.sh
```

The script installs `workspace/root/AGENTS.md`, `workspace/root/Makefile`, and `workspace/root/scripts/git-status.py` at the workspace root, clones the public repositories in `repos.tsv`, checks the origin URL and branch of existing checkouts, and creates `.agents/skills/` symlinks. The bootstrap repository's own root `AGENTS.md` only guides maintenance of that repository; it is **not** the installed workspace guide. The script does not pull or change an existing checkout. On later runs, it reports locally edited root files for review rather than overwriting them.

Git and access to GitHub are required. The public list uses HTTPS, so no SSH key is needed for those repositories. Private repositories require your own GitHub access.

To add repositories you can access, create `.bootstrap/polyagent/workspace/repos.local.tsv` with the same tab-separated columns as `repos.tsv`: directory name, clone URL, and branch. This file is ignored by Git. The script will report a failed clone and continue with the remaining repositories if access is missing. For example:

```text
# directory<TAB>clone URL<TAB>branch
my-private-repo<TAB>git@github.com:my-org/my-private-repo.git<TAB>main
```

Replace the literal `<TAB>` markers in that example with tab characters. Keep private repository names and URLs out of this public repository unless their owners have approved publishing them.

The script links the bundled `polyagent-workspace` skill. If an authorized `teamSkills/` checkout is present (for example, through your local manifest), it links each of its skill directories too. Team members can use that repository's workspace inventory to identify additional private checkouts, add their URLs to `repos.local.tsv`, and rerun this script.

After initialization, read the installed root `AGENTS.md` and the `AGENTS.md` of the child repository you will work in. Run `make help` to see the local preview and status commands. Each child repository has its own build, tests, and Git workflow.
