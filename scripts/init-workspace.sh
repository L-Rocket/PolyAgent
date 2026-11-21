#!/usr/bin/env bash
set -uo pipefail

bootstrap_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ "$(basename "$(dirname "$bootstrap_root")")" != .bootstrap ]; then
  echo "Clone this repository into <workspace>/.bootstrap/polyagent before running the script." >&2
  exit 1
fi
workspace_root="$(cd "$bootstrap_root/../.." && pwd)"
if [ -e "$workspace_root/.git" ]; then
  echo "The workspace root must not be a Git repository: $workspace_root" >&2
  exit 1
fi
cd "$workspace_root" || exit 1
failed=0

install_root_file() {
  local relative="$1" source="$bootstrap_root/workspace/root/$1" target="$workspace_root/$1"
  if [ -L "$target" ]; then
    echo "FAILED $relative: expected a regular file, found a symlink" >&2
    failed=1
  elif [ ! -e "$target" ]; then
    mkdir -p "$(dirname "$target")"
    if cp "$source" "$target"; then
      echo "Installed $relative"
    else
      failed=1
    fi
  elif ! cmp -s "$source" "$target"; then
    echo "CHECK $relative: local copy differs from the bootstrap source; review and merge updates" >&2
  else
    echo "OK $relative: matches bootstrap source"
  fi
}

install_root_file AGENTS.md
install_root_file Makefile
install_root_file scripts/git-status.py

process_manifest() {
  local manifest="$1" directory url branch path actual_remote actual_branch
  while IFS=$'\t' read -r directory url branch || [ -n "$directory" ]; do
    [[ -z "$directory" || "$directory" == \#* ]] && continue
    if [[ ! "$directory" =~ ^[A-Za-z0-9._-]+$ || "$directory" == . || "$directory" == .. || "$directory" == .bootstrap || "$directory" == .agents || "$directory" == scripts || -z "$url" || -z "$branch" ]]; then
      echo "Invalid entry in $manifest: $directory" >&2
      failed=1
      continue
    fi
    path="$workspace_root/$directory"
    if [ ! -e "$path" ]; then
      echo "Cloning $directory"
      if ! GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=never git clone --branch "$branch" -- "$url" "$path"; then
        echo "FAILED: $directory could not be cloned (check URL and access)" >&2
        failed=1
        continue
      fi
    elif [ ! -d "$path/.git" ] && [ ! -f "$path/.git" ]; then
      echo "FAILED: $directory exists but is not a Git checkout" >&2
      failed=1
      continue
    fi
    actual_remote="$(git -C "$path" remote get-url origin 2>/dev/null || true)"
    actual_branch="$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
    if [ "$actual_remote" != "$url" ] || [ "$actual_branch" != "$branch" ]; then
      echo "CHECK $directory: origin=$actual_remote (expected $url), branch=$actual_branch (expected $branch)" >&2
      failed=1
    else
      echo "OK $directory: origin and branch verified"
    fi
  done < "$manifest"
}

process_manifest "$bootstrap_root/workspace/repos.tsv"
if [ -f "$bootstrap_root/workspace/repos.local.tsv" ]; then
  process_manifest "$bootstrap_root/workspace/repos.local.tsv"
fi

mkdir -p "$workspace_root/.agents/skills"
link_skills() {
  local source="$1" prefix="$2" skill name link target
  for skill in "$source"/*/; do
    [ -f "$skill/SKILL.md" ] || continue
    name="$(basename "$skill")"
    link="$workspace_root/.agents/skills/$name"
    target="../../$prefix/$name"
    if [ -e "$link" ] && [ ! -L "$link" ]; then
      echo "CHECK skill $name: path exists and is not a symlink" >&2
      failed=1
      continue
    fi
    ln -sfn "$target" "$link"
    if [ -L "$link" ] && [ -e "$link" ]; then
      echo "OK skill $name: $target"
    else
      echo "FAILED skill $name: link target missing" >&2
      failed=1
    fi
  done
}
link_skills "$bootstrap_root/workspace/skills" ".bootstrap/$(basename "$bootstrap_root")/workspace/skills"
if [ -d "$workspace_root/teamSkills" ]; then
  link_skills "$workspace_root/teamSkills" "teamSkills"
fi
for link in "$workspace_root/.agents/skills"/*; do
  if [ -L "$link" ] && [ ! -e "$link" ]; then
    rm "$link"
    echo "Removed stale skill link: $(basename "$link")"
  fi
done

if [ "$failed" -eq 0 ]; then
  echo "PolyAgent workspace initialized."
else
  echo "PolyAgent workspace initialized with checks or failures; review the messages above." >&2
fi
exit "$failed"
