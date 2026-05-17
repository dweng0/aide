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
  for f in manifest.md history_index.md user-planner.md daily-goals.md; do
    [ -f "$CONTEXT_DIR/$f" ]
  done
}

@test "does not create goals-archive.md" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -f "$CONTEXT_DIR/goals-archive.md" ]
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

@test "adds scripts to PATH in .zshrc" {
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "aide" "$HOME/.zshrc"
}

@test "does not duplicate PATH entry in .zshrc on re-run" {
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME"
  bash "$SCRIPT"
  run bash "$SCRIPT"
  count=$(grep -c "added by aide" "$HOME/.zshrc")
  [ "$count" -eq 1 ]
}

@test "manifest.md is regenerated with current repo path on re-run" {
  bash "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "cleanup_planner:" "$CONTEXT_DIR/manifest.md"
  grep -q "filter_emails:" "$CONTEXT_DIR/manifest.md"
}

@test "manifest.md contains filter_emails path" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "filter_emails:" "$CONTEXT_DIR/manifest.md"
}

@test "seeds email-filter.md with default blocklist" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$CONTEXT_DIR/email-filter.md" ]
  grep -q "noreply@" "$CONTEXT_DIR/email-filter.md"
}

@test "does not overwrite existing email-filter.md on re-run" {
  bash "$SCRIPT"
  printf "# custom blocklist\n- custom@example.com\n" > "$CONTEXT_DIR/email-filter.md"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "custom@example.com" "$CONTEXT_DIR/email-filter.md"
}

@test "does not create .env (credentials handled by MCP)" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -f "$CONTEXT_DIR/.env" ]
}

@test "does not create daily-briefing directory (no pre-fetch files needed)" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -d "$CONTEXT_DIR/daily-briefing" ]
}
