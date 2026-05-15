#!/usr/bin/env bats

SKILL_MD="$BATS_TEST_DIRNAME/../skills/todays-goals/SKILL.md"
SKILL_JSON="$BATS_TEST_DIRNAME/../skills/todays-goals.json"

@test "SKILL.md has name frontmatter" {
  grep -q "^name:" "$SKILL_MD"
}

@test "SKILL.md has description frontmatter" {
  grep -q "^description:" "$SKILL_MD"
}

@test "SKILL.md references daily-goals.md" {
  grep -q "daily-goals.md" "$SKILL_MD"
}

@test "SKILL.md specifies ## heading and - [ ] subtask format" {
  grep -q "^##" "$SKILL_MD" || grep -q '##' "$SKILL_MD"
  grep -q -- '- \[ \]' "$SKILL_MD"
}

@test "SKILL.md requires follow-up questions per goal" {
  grep -q "follow.up" "$SKILL_MD"
}

@test "SKILL.md handles re-run without duplicating headings" {
  grep -q "duplicate" "$SKILL_MD" || grep -q "append" "$SKILL_MD"
}

@test "todays-goals.json is valid JSON with required keys" {
  python3 -c "
import json
with open('$SKILL_JSON') as f:
    d = json.load(f)
for key in ('name', 'description', 'triggers', 'instructions'):
    assert key in d, f'missing key: {key}'
for phrase in ('daily-goals.md', '- [ ]', 'follow-up'):
    assert phrase in d['instructions'], f'instructions missing: {phrase}'
"
}
