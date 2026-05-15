#!/bin/bash

NOTES_DIR="${NOTES_DIR:-$HOME/notes}"
CONTEXT_DIR="${CONTEXT_DIR:-$HOME/.notes-context}"
TODAY="${TODAY:-$(date '+%d-%m-%y')}"
YESTERDAY="${YESTERDAY:-$(date -v-1d '+%d-%m-%y')}"
NO_EDITOR="${NO_EDITOR:-0}"

note_file="$NOTES_DIR/$TODAY.md"

mkdir -p "$NOTES_DIR" "$CONTEXT_DIR"

if [ -f "$note_file" ]; then
  [ "$NO_EDITOR" = "1" ] || source "$(dirname "$0")/note_taker.sh" "$note_file"
  exit 0
fi

goals_file="$CONTEXT_DIR/daily-goals.md"
if [ -s "$goals_file" ]; then
  goals_archive="$CONTEXT_DIR/goals-archive.md"
  printf "## %s\n" "$YESTERDAY" >> "$goals_archive"
  cat "$goals_file" >> "$goals_archive"
  printf "\n" >> "$goals_archive"
  : > "$goals_file"
fi

touch "$note_file"
printf -- "---\ntitle: notes for %s\n---\n" "$TODAY" >> "$note_file"

history_index="$CONTEXT_DIR/history_index.md"
if ! grep -q "$TODAY.md" "$history_index" 2>/dev/null; then
  printf -- '- `%s.md`\n' "$TODAY" >> "$history_index"
fi

[ "$NO_EDITOR" = "1" ] || source "$(dirname "$0")/note_taker.sh" "$note_file"
