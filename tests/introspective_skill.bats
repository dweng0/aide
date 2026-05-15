#!/usr/bin/env bats

SKILL_MD="$BATS_TEST_DIRNAME/../skills/introspective/SKILL.md"
SKILL_JSON="$BATS_TEST_DIRNAME/../skills/introspective.json"

@test "SKILL.md has name frontmatter" {
  grep -q "^name:" "$SKILL_MD"
}

@test "SKILL.md has description frontmatter" {
  grep -q "^description:" "$SKILL_MD"
}

@test "SKILL.md references today's note in ~/notes/" {
  grep -q '~/notes/' "$SKILL_MD"
}

@test "SKILL.md references daily-goals.md" {
  grep -q "daily-goals.md" "$SKILL_MD"
}

@test "SKILL.md references user-planner.md" {
  grep -q "user-planner.md" "$SKILL_MD"
}

@test "SKILL.md distinguishes on-track drifting and unaddressed" {
  grep -qi "on.track" "$SKILL_MD"
  grep -qi "drift" "$SKILL_MD"
  grep -qi "unaddressed" "$SKILL_MD"
}

@test "SKILL.md handles empty daily-goals.md" {
  grep -q "empty" "$SKILL_MD"
}

@test "introspective.json is valid JSON with required keys" {
  python3 -c "
import json
with open('$SKILL_JSON') as f:
    d = json.load(f)
for key in ('name', 'description', 'triggers', 'instructions'):
    assert key in d, f'missing key: {key}'
for phrase in ('daily-goals.md', 'user-planner.md', '~/notes/', 'on-track', 'drifting', 'unaddressed'):
    assert phrase in d['instructions'], f'instructions missing: {phrase}'
"
}
