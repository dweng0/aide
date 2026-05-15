#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../scripts/note_organizer.sh"

setup() {
  TMPDIR=$(mktemp -d)
  export NOTES_DIR="$TMPDIR/notes"
  export CONTEXT_DIR="$TMPDIR/context"
  export NO_EDITOR=1
  export TODAY="15-05-26"
  export YESTERDAY="14-05-26"
  mkdir -p "$NOTES_DIR" "$CONTEXT_DIR"
  printf "## Recent Files\n" > "$CONTEXT_DIR/history_index.md"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "creates today's note file on first run" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$NOTES_DIR/15-05-26.md" ]
}

@test "appends filename to history_index.md on creation" {
  run bash "$SCRIPT"
  grep -q "15-05-26.md" "$CONTEXT_DIR/history_index.md"
}

@test "skips history update when note already exists" {
  touch "$NOTES_DIR/15-05-26.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  # history_index.md still has only the initial header, no new entry
  [ "$(wc -l < "$CONTEXT_DIR/history_index.md")" -eq 1 ]
}

@test "archives daily-goals.md with yesterday's date header on a new day" {
  printf "## Goal A\n- [x] done\n" > "$CONTEXT_DIR/daily-goals.md"
  run bash "$SCRIPT"
  [ -f "$CONTEXT_DIR/goals-archive.md" ]
  grep -q "## $YESTERDAY" "$CONTEXT_DIR/goals-archive.md"
}

@test "preserves checkbox state in goals archive" {
  printf -- "- [x] completed task\n- [ ] open task\n" > "$CONTEXT_DIR/daily-goals.md"
  run bash "$SCRIPT"
  grep -q "\- \[x\] completed task" "$CONTEXT_DIR/goals-archive.md"
  grep -q "\- \[ \] open task" "$CONTEXT_DIR/goals-archive.md"
}

@test "clears daily-goals.md after archiving" {
  printf "some goals\n" > "$CONTEXT_DIR/daily-goals.md"
  run bash "$SCRIPT"
  [ -f "$CONTEXT_DIR/daily-goals.md" ]
  [ ! -s "$CONTEXT_DIR/daily-goals.md" ]
}

@test "does not archive when daily-goals.md is empty" {
  touch "$CONTEXT_DIR/daily-goals.md"
  run bash "$SCRIPT"
  [ ! -f "$CONTEXT_DIR/goals-archive.md" ]
}
