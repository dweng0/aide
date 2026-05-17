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

@test "appends daily goals to yesterday's note under a Goals section" {
  printf "## Ship feature\n- [x] write tests\n- [ ] deploy\n" > "$CONTEXT_DIR/daily-goals.md"
  touch "$NOTES_DIR/$YESTERDAY.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "## Goals" "$NOTES_DIR/$YESTERDAY.md"
  grep -q "## Ship feature" "$NOTES_DIR/$YESTERDAY.md"
}

@test "clears daily-goals.md after appending to yesterday's note" {
  printf "some goals\n" > "$CONTEXT_DIR/daily-goals.md"
  touch "$NOTES_DIR/$YESTERDAY.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$CONTEXT_DIR/daily-goals.md" ]
  [ ! -s "$CONTEXT_DIR/daily-goals.md" ]
}

@test "clears daily-goals.md even when yesterday's note does not exist" {
  printf "some goals\n" > "$CONTEXT_DIR/daily-goals.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -s "$CONTEXT_DIR/daily-goals.md" ]
}

@test "does not create goals-archive.md" {
  printf "## Goal A\n- [x] done\n" > "$CONTEXT_DIR/daily-goals.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -f "$CONTEXT_DIR/goals-archive.md" ]
}
