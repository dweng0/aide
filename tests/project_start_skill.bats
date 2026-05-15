#!/usr/bin/env bats

SKILL_MD="$BATS_TEST_DIRNAME/../skills/project-start/SKILL.md"
SKILL_JSON="$BATS_TEST_DIRNAME/../skills/project-start.json"

@test "SKILL.md has name frontmatter" {
  grep -q "^name:" "$SKILL_MD"
}

@test "SKILL.md has description frontmatter" {
  grep -q "^description:" "$SKILL_MD"
}

@test "SKILL.md references project-context.md" {
  grep -q "project-context.md" "$SKILL_MD"
}

@test "SKILL.md references stakeholders.md" {
  grep -q "stakeholders.md" "$SKILL_MD"
}

@test "SKILL.md specifies ~/.notes-context/projects/ output path" {
  grep -q "\.notes-context/projects/" "$SKILL_MD"
}

@test "SKILL.md covers end goal interview field" {
  grep -qi "end goal" "$SKILL_MD"
}

@test "SKILL.md covers MVP interview field" {
  grep -q "MVP" "$SKILL_MD"
}

@test "SKILL.md covers timelines interview field" {
  grep -qi "timelines" "$SKILL_MD"
}

@test "SKILL.md covers stakeholders interview field" {
  grep -qi "stakeholders" "$SKILL_MD"
}

@test "SKILL.md documents re-run warn and update behaviour" {
  grep -q "already" "$SKILL_MD"
  grep -qi "update" "$SKILL_MD"
}

@test "project-start.json is valid JSON with required keys" {
  python3 -c "
import json
with open('$SKILL_JSON') as f:
    d = json.load(f)
for key in ('name', 'description', 'triggers', 'instructions'):
    assert key in d, f'missing key: {key}'
assert d['name'] == 'project-start', 'name must be project-start'
assert 'project-start' in d['triggers'], 'triggers must include project-start'
"
}
