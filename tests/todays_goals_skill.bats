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

# Calendar and email phases (#0016)

@test "SKILL.md uses Google Calendar MCP for calendar events" {
  grep -qi "google calendar\|calendar mcp\|mcp.*calendar" "$SKILL_MD"
}

@test "SKILL.md reads daily-briefing/emails.md" {
  grep -q "emails.md" "$SKILL_MD"
}

@test "SKILL.md skips calendar phase silently if file absent" {
  grep -q "absent\|missing\|not exist\|skip" "$SKILL_MD"
}

@test "SKILL.md surfaces stakeholder emails" {
  grep -qi "stakeholder" "$SKILL_MD"
}

@test "SKILL.md surfaces action-implied emails" {
  grep -qi "action\|reply\|decide\|act" "$SKILL_MD"
}

# Deliverables phase (#0017)

@test "SKILL.md references roadmap.md" {
  grep -q "roadmap.md" "$SKILL_MD"
}

@test "SKILL.md surfaces Now-horizon deliverables only" {
  grep -qi "now\|Now horizon" "$SKILL_MD"
}

@test "SKILL.md skips blocked deliverables" {
  grep -qi "block" "$SKILL_MD"
}

@test "SKILL.md never modifies roadmap.md" {
  grep -qi "never modif\|read.only\|not modif\|does not modif\|roadmap.*never\|never.*roadmap" "$SKILL_MD"
}

@test "SKILL.md handles no-roadmap case silently" {
  grep -qi "no.*roadmap\|roadmap.*absent\|skip.*silently\|silently.*skip" "$SKILL_MD"
}

@test "SKILL.md handles multiple-project case by asking user to pick" {
  grep -qi "multiple\|which project\|pick\|choose\|select" "$SKILL_MD"
}
