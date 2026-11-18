#!/usr/bin/env bash
# Apply the overlay patches to a GridCraft checkout, on top of the latest upstream main.
#
#   ./apply.sh [path/to/gridcraft]      (default: ../gridcraft; cloned if missing)
#
# Result: branch `omarchy-palette` = upstream main + patches/*.patch.
# If that branch already exists, its old tip is kept as `omarchy-palette-prev`.
# If a patch no longer applies, `git am` stops so you can resolve the conflict;
# afterwards run ./refresh.sh to save the updated patch here.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GC="${1:-$HERE/../gridcraft}"
UPSTREAM_URL="${GRIDCRAFT_UPSTREAM:-https://github.com/storytold/gridcraft.git}"
BRANCH="${OVERLAY_BRANCH:-omarchy-palette}"

if [ ! -d "$GC/.git" ]; then
  git clone "$UPSTREAM_URL" "$GC"
fi
cd "$GC"

if [ -n "$(git status --porcelain)" ]; then
  echo "error: $GC has uncommitted changes; commit or stash them first." >&2
  exit 1
fi
if [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; then
  echo "error: a rebase or 'git am' is in progress in $GC; finish or abort it first." >&2
  exit 1
fi

# Use whichever remote points at storytold/gridcraft (usually origin).
REMOTE="$(git remote -v | awk '/storytold\/gridcraft(\.git)? \(fetch\)/ {print $1; exit}')"
REMOTE="${REMOTE:-origin}"
git fetch "$REMOTE" main

if git rev-parse --verify -q "refs/heads/$BRANCH" >/dev/null; then
  git branch -f "$BRANCH-prev" "$BRANCH"
  echo "Previous $BRANCH saved as $BRANCH-prev"
fi
git switch -C "$BRANCH" "$REMOTE/main"
git am -3 "$HERE"/patches/*.patch

echo
echo "Done: $BRANCH = $REMOTE/main ($(git rev-parse --short "$REMOTE/main")) + $(ls "$HERE"/patches/*.patch | wc -l) patch(es)."
echo "Build: cargo run --release -p gridcraft"
