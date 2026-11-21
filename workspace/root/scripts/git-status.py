"""Report Git changes across the workspace without updating Git state."""

import os
from pathlib import Path
import subprocess


def git(path, *args):
    return subprocess.check_output(
        ["git", "-C", str(path), *args],
        encoding="utf-8",
        errors="replace",
        env={**os.environ, "GIT_OPTIONAL_LOCKS": "0", "GIT_NO_LAZY_FETCH": "1"},
    ).strip("\n")


def main():
    root = Path(__file__).resolve().parent.parent
    repositories = set()
    worktree_count = 0
    failures = 0
    print("Git status compared with locally cached remote-tracking refs.")

    for path in sorted(root.iterdir()):
        if not (path / ".git").exists():
            continue
        try:
            common = git(path, "rev-parse", "--path-format=absolute", "--git-common-dir")
            if common in repositories:
                continue
            repositories.add(common)
            worktrees = git(path, "worktree", "list", "--porcelain", "-z")
            detached_heads = []
            label = Path(common).parent.name
            print(f"\n{label}")
            for record in worktrees.split("\0\0"):
                fields = record.split("\0")
                worktree = Path(fields[0].removeprefix("worktree "))
                if not fields[0] or "bare" in fields or not worktree.is_dir():
                    continue
                worktree_count += 1
                status = git(worktree, "status", "--short", "--branch", "--untracked-files=normal")
                print(f"  {worktree}")
                for line in status.splitlines():
                    print(f"    {line}")
                if "detached" in fields:
                    detached_heads.append(git(worktree, "rev-parse", "HEAD"))

            commits = git(path, "log", "--branches", *detached_heads, "--not", "--remotes",
                          "--format=%h %d %s")
            if commits:
                print("  Commits absent from remote-tracking refs:")
                for line in commits.splitlines():
                    print(f"    {line}")
        except subprocess.CalledProcessError:
            print(f"  Could not finish scanning {path}.")
            failures += 1

    print(f"\nScanned {len(repositories)} repositories and {worktree_count} worktrees.")
    return int(failures > 0)


if __name__ == "__main__":
    raise SystemExit(main())
