# Initialize a PolyAgent workspace

Create a workspace directory and clone [L-Rocket/PolyAgent](https://github.com/L-Rocket/PolyAgent) into its hidden `.bootstrap/polyagent/` child. The **workspace root is not a Git repository**; each project checkout has its own `.git`.

```bash
mkdir -p PolyAgent-workspace/.bootstrap
git clone https://github.com/L-Rocket/PolyAgent.git PolyAgent-workspace/.bootstrap/polyagent
cd PolyAgent-workspace
.bootstrap/polyagent/scripts/init-workspace.sh
```

The script installs `workspace/root/AGENTS.md`, `workspace/root/Makefile`, and `workspace/root/scripts/git-status.py` at the workspace root, then clones the 13 repositories in `repos.tsv`, including CubeSandbox. It checks the origin URL and branch of existing checkouts and creates `.agents/skills/` symlinks. The bootstrap repository's own root `AGENTS.md` only guides maintenance of that repository; it is **not** the installed workspace guide. The script does not pull or change an existing checkout. On later runs, it reports locally edited root files for review rather than overwriting them.

Git and access to GitHub are required. The default manifest uses HTTPS and was checked without local credentials. The other four known repositories are listed in `repos.restricted.tsv`. After your GitHub access is configured, run `.bootstrap/polyagent/scripts/init-workspace.sh --include-restricted` to attempt them. Failed clones do not stop later checkouts; the script reports an incomplete workspace and exits nonzero. It never installs credentials.

Publicly cloneable does not itself mean open-source licensed. Check each repository's license before reusing its code; the bootstrap only establishes a local checkout.

To add repositories beyond the known set, create `.bootstrap/polyagent/workspace/repos.local.tsv` with the same tab-separated columns as `repos.tsv`: directory name, clone URL, and branch. This file is ignored by Git. For example:

```text
# directory<TAB>clone URL<TAB>branch
my-private-repo<TAB>git@github.com:my-org/my-private-repo.git<TAB>main
```

Replace the literal `<TAB>` markers in that example with tab characters. The checked-in restricted manifest already names the four known access-controlled repositories. Keep credentials and any additional private repository URLs in local files unless their owners approve publication.

The script links the bundled `polyagent-workspace` skill. If the restricted `teamSkills/` checkout succeeds, it also links each of its skill directories. Temporary preview/release worktrees from an existing repository are not separate manifest entries; create them only when a task needs them.

After initialization, read the installed root `AGENTS.md` and the `AGENTS.md` of the child repository you will work in. Run `make help` to see the local preview and status commands. Each child repository has its own build, tests, and Git workflow.
