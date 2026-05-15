#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../install.sh"

setup() {
  TMPDIR=$(mktemp -d)
  export AIDE_REPO="$BATS_TEST_DIRNAME/.."
  export NOTES_DIR="$TMPDIR/notes"
  export CONTEXT_DIR="$TMPDIR/context"
  export FISH_CONF_DIR="$TMPDIR/fish/conf.d"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "creates notes dir when absent" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -d "$NOTES_DIR" ]
}

@test "creates all context files when absent" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  for f in manifest.md history_index.md user-planner.md daily-goals.md goals-archive.md; do
    [ -f "$CONTEXT_DIR/$f" ]
  done
}

@test "does not overwrite existing context files on re-run" {
  mkdir -p "$CONTEXT_DIR"
  printf "existing content\n" > "$CONTEXT_DIR/user-planner.md"
  bash "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  run grep "existing content" "$CONTEXT_DIR/user-planner.md"
  [ "$status" -eq 0 ]
}

@test "writes fish_add_path line to aide.fish" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$FISH_CONF_DIR/aide.fish" ]
  grep -q "fish_add_path" "$FISH_CONF_DIR/aide.fish"
}

@test "does not duplicate fish_add_path entry on re-run" {
  bash "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  count=$(grep -c "fish_add_path" "$FISH_CONF_DIR/aide.fish")
  [ "$count" -eq 1 ]
}
