# gridcraft-omarchy

An overlay for [GridCraft](https://github.com/storytold/gridcraft) that adds a
**Desktop colors** interface theme on Linux. It follows the current Omarchy
theme live. GridCraft reads `~/.local/state/omarchy/current/theme/colors.toml`
(background, its darker steps, foreground and accent) and redraws the window
chrome when you switch themes. The sheet keeps its own colours.

Pick **Desktop colors** under **Display theme** (View tab, or File ▸ Options ▸
General), or run the `view.theme` command with `{"mode":"desktop"}`.

This repo holds only the patch, not a fork of GridCraft.

## Use

```sh
git clone <this repo> ~/Projects/gridcraft-omarchy
cd ~/Projects/gridcraft-omarchy
./apply.sh ~/Projects/gridcraft      # clones GridCraft there if it is missing
cd ~/Projects/gridcraft && cargo run --release -p gridcraft
```

`apply.sh` fetches upstream `main`, resets the `omarchy-palette` branch to it
and applies `patches/*.patch` with `git am -3`. It refuses to run on a dirty
tree. A previous `omarchy-palette` tip is kept as `omarchy-palette-prev`.

## Updating to newer GridCraft

Run `./apply.sh` again. If upstream changed the same lines, `git am` stops on
the conflict:

```sh
cd ~/Projects/gridcraft
# fix the conflicted files, then
git add -A && git am --continue
cd ~/Projects/gridcraft-omarchy && ./refresh.sh ~/Projects/gridcraft
git commit -am "Rebase onto gridcraft <short-sha>"
```

`refresh.sh` re-exports the commits on `omarchy-palette` (from upstream `main`)
into `patches/`. Use it after any change to the overlay commits.

## Licence

The patch modifies GridCraft and is offered under the same terms: MIT OR
Apache-2.0 (`LICENSE-MIT`, `LICENSE-APACHE`).
