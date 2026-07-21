#!/usr/bin/env bash
# Copies skill directories into the skill dirs for Claude and Codex,
# overwriting existing copies so they stay in sync with this repo.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
DESTINATIONS=(
  "$HOME/.claude/skills"
  "$HOME/.codex/skills"
)

for dst in "${DESTINATIONS[@]}"; do
  echo "Installing skills to: $dst"
  mkdir -p "$dst"

  for dir in "$SKILLS_SRC"/*/; do
    name="$(basename "$dir")"
    target="$dst/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
      echo "  updating: $name"
      # Remove the existing copy (or leftover symlink from the old install
      # method) first, so files deleted from the repo's skill don't linger
      # in the installed copy and symlinks get replaced with real copies.
      rm -rf "$target"
    else
      echo "  copying:  $name"
    fi
    cp -R "$dir" "$target"
  done
done
