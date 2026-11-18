#!/usr/bin/env bash
# Save the overlay commits from a GridCraft checkout back into patches/.
#
#   ./refresh.sh [path/to/gridcraft]    (default: ../gridcraft)
#
# Run it after resolving a conflict from ./apply.sh, or after changing the
# overlay commits on the `omarchy-palette` branch. Then commit here.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GC="${1:-$HERE/../gridcraft}"
BRANCH="${OVERLAY_BRANCH:-omarchy-palette}"
cd "$GC"

if [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; then
  echo "error: finish the 'git am' / rebase in $GC first (git am --continue)." >&2
  exit 1
fi

REMOTE="$(git remote -v | awk '/storytold\/gridcraft(\.git)? \(fetch\)/ {print $1; exit}')"
REMOTE="${REMOTE:-origin}"
BASE="$(git merge-base "$REMOTE/main" "$BRANCH")"

rm -f "$HERE"/patches/*.patch
git format-patch -q "$BASE..$BRANCH" -o "$HERE/patches"
echo "Wrote $(ls "$HERE"/patches/*.patch | wc -l) patch(es), based on $(git rev-parse --short "$BASE")."
echo "Review with 'git -C $HERE diff', then commit."
