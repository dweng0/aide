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

# Credential setup tests (#0013)

run_with_creds() {
  printf "jmartinsmith@gmail.com\ntest_app_password_16\n" \
    | bash "$SCRIPT"
}

@test "creates daily-briefing directory" {
  run_with_creds
  [ -d "$CONTEXT_DIR/daily-briefing" ]
}

@test "creates .env with GMAIL_ADDRESS" {
  run_with_creds
  grep -q "GMAIL_ADDRESS=" "$CONTEXT_DIR/.env"
}

@test "creates .env with GMAIL_APP_PASSWORD" {
  run_with_creds
  grep -q "GMAIL_APP_PASSWORD=" "$CONTEXT_DIR/.env"
}

@test ".env values match what was entered" {
  run_with_creds
  grep -q "GMAIL_ADDRESS=jmartinsmith@gmail.com" "$CONTEXT_DIR/.env"
  grep -q "GMAIL_APP_PASSWORD=test_app_password_16" "$CONTEXT_DIR/.env"
}

@test "seeds email-filter.md with default blocklist" {
  run_with_creds
  [ -f "$CONTEXT_DIR/email-filter.md" ]
  grep -q "noreply@" "$CONTEXT_DIR/email-filter.md"
}

@test "does not overwrite existing .env on re-run" {
  run_with_creds
  printf "GMAIL_ADDRESS=original@example.com\nGMAIL_APP_PASSWORD=original_pw\n" > "$CONTEXT_DIR/.env"
  run_with_creds
  grep -q "original@example.com" "$CONTEXT_DIR/.env"
}

@test "does not overwrite existing email-filter.md on re-run" {
  run_with_creds
  printf "# custom blocklist\n- custom@example.com\n" > "$CONTEXT_DIR/email-filter.md"
  run_with_creds
  grep -q "custom@example.com" "$CONTEXT_DIR/email-filter.md"
}

@test "prints instructions before prompting for credentials" {
  output=$(printf "jmartinsmith@gmail.com\ntest_app_password_16\n" \
    | bash "$SCRIPT" 2>&1)
  echo "$output" | grep -qi "app password\|gmail"
}
