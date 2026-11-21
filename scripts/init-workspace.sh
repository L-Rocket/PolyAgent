#!/usr/bin/env bash
set -uo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1
failed=0

exclude_child() {
  local directory="$1" exclude="$root/.git/info/exclude"
  if [ -f "$exclude" ] && ! grep -Fxq "/$directory/" "$exclude"; then
    printf '/%s/\n' "$directory" >> "$exclude"
  fi
}

process_manifest() {
  local manifest="$1" directory url branch path actual_remote actual_branch
  while IFS=$'\t' read -r directory url branch || [ -n "$directory" ]; do
    [[ -z "$directory" || "$directory" == \#* ]] && continue
    if [[ ! "$directory" =~ ^[A-Za-z0-9._-]+$ || "$directory" == . || "$directory" == .. || "$directory" == assets || "$directory" == scripts || "$directory" == workspace || "$directory" == .agents || -z "$url" || -z "$branch" ]]; then
      echo "Invalid entry in $manifest: $directory" >&2
      failed=1
      continue
    fi
    path="$root/$directory"
    exclude_child "$directory"
    if [ ! -e "$path" ]; then
      echo "Cloning $directory"
      if ! git clone --branch "$branch" -- "$url" "$path"; then
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

process_manifest "$root/workspace/repos.tsv"
if [ -f "$root/workspace/repos.local.tsv" ]; then
  process_manifest "$root/workspace/repos.local.tsv"
fi

mkdir -p "$root/.agents/skills"
link_skills() {
  local source="$1" prefix="$2" skill name link target
  for skill in "$source"/*/; do
    [ -f "$skill/SKILL.md" ] || continue
    name="$(basename "$skill")"
    link="$root/.agents/skills/$name"
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
link_skills "$root/workspace/skills" "workspace/skills"
if [ -d "$root/teamSkills" ]; then
  link_skills "$root/teamSkills" "teamSkills"
fi

if [ "$failed" -eq 0 ]; then
  echo "PolyAgent workspace initialized."
else
  echo "PolyAgent workspace initialized with checks or failures; review the messages above." >&2
fi
exit "$failed"
