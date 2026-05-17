#!/usr/bin/env bats

SKILL_MD="$BATS_TEST_DIRNAME/../skills/retrospective/SKILL.md"
SKILL_JSON="$BATS_TEST_DIRNAME/../skills/retrospective.json"

@test "SKILL.md has name frontmatter" {
  grep -q "^name:" "$SKILL_MD"
}

@test "SKILL.md has description frontmatter" {
  grep -q "^description:" "$SKILL_MD"
}

@test "SKILL.md references user-planner.md" {
  grep -q "user-planner.md" "$SKILL_MD"
}

@test "SKILL.md references ~/notes/ and 14-day fallback window" {
  grep -q '~/notes/' "$SKILL_MD"
  grep -q "14 days" "$SKILL_MD"
}

@test "SKILL.md uses last_scanned from manifest for incremental scans" {
  grep -q "last_scanned" "$SKILL_MD"
  grep -q "manifest.md" "$SKILL_MD"
}

@test "SKILL.md updates last_scanned after session" {
  grep -q "last_scanned" "$SKILL_MD"
}

@test "SKILL.md references cleanup_planner.py" {
  grep -q "cleanup_planner.py" "$SKILL_MD"
}

@test "SKILL.md specifies planner entry format" {
  grep -q -- '- \[ \]' "$SKILL_MD"
  grep -q 'see ~/notes/' "$SKILL_MD"
}

@test "retrospective.json is valid JSON with required keys" {
  python3 -c "
import json, sys
with open('$SKILL_JSON') as f:
    d = json.load(f)
for key in ('name', 'description', 'triggers', 'instructions'):
    assert key in d, f'missing key: {key}'
for phrase in ('user-planner.md', '~/notes/', '14 days', 'cleanup_planner.py'):
    assert phrase in d['instructions'], f'instructions missing: {phrase}'
"
}
