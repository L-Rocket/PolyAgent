# Initialize a PolyAgent workspace

Clone [L-Rocket/PolyAgent](https://github.com/L-Rocket/PolyAgent) and use its directory as the workspace root. Run `scripts/init-workspace.sh` there. The script clones the public repositories in `repos.tsv`, checks the origin URL and branch of existing checkouts, and creates `.agents/skills/` symlinks. It does not pull or change an existing checkout.

Git and access to GitHub are required. The public list uses HTTPS, so no SSH key is needed for those repositories. Private repositories require your own GitHub access.

To add repositories you can access, create `workspace/repos.local.tsv` with the same tab-separated columns as `repos.tsv`: directory name, clone URL, and branch. This file is ignored by Git. The script will report a failed clone and continue with the remaining repositories if access is missing. For example:

```text
# directory<TAB>clone URL<TAB>branch
my-private-repo<TAB>git@github.com:my-org/my-private-repo.git<TAB>main
```

Replace the literal `<TAB>` markers in that example with tab characters. Keep private repository names and URLs out of this public repository unless their owners have approved publishing them.

The script links the bundled `polyagent-workspace` skill. If a `teamSkills/` checkout is present (for example, through your local manifest), it links each of its skill directories too. It records cloned child-directory names in this checkout's `.git/info/exclude` so they do not appear as untracked files in the PolyAgent repository. That exclude file is local to each clone.

After initialization, read the root `AGENTS.md` and the `AGENTS.md` of the child repository you will work in. Each child repository has its own build, tests, and Git workflow.
