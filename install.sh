#!/bin/bash
set -e

REPO="${AIDE_REPO:-$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd)}"
NOTES_DIR="${NOTES_DIR:-$HOME/notes}"
CONTEXT_DIR="${CONTEXT_DIR:-$HOME/.notes-context}"
FISH_CONF_DIR="${FISH_CONF_DIR:-$HOME/.config/fish/conf.d}"

mkdir -p "$NOTES_DIR"
mkdir -p "$CONTEXT_DIR"
mkdir -p "$CONTEXT_DIR/projects"
mkdir -p "$FISH_CONF_DIR"

for f in manifest.md history_index.md user-planner.md daily-goals.md goals-archive.md; do
  target="$CONTEXT_DIR/$f"
  if [ ! -f "$target" ]; then
    case "$f" in
      manifest.md)      printf "# aide manifest\n" > "$target" ;;
      history_index.md) printf "## Recent Files\n" > "$target" ;;
      *)                touch "$target" ;;
    esac
  fi
done

fish_file="$FISH_CONF_DIR/aide.fish"
path_line="fish_add_path $REPO/scripts"
if [ ! -f "$fish_file" ] || ! grep -qF "$path_line" "$fish_file"; then
  printf "%s\n" "$path_line" >> "$fish_file"
fi

printf "aide installed.\n"
printf "  notes dir:    %s\n" "$NOTES_DIR"
printf "  context dir:  %s\n" "$CONTEXT_DIR"
printf "  fish config:  %s\n" "$fish_file"
