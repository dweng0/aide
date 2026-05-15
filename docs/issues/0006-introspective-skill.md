# #6 — Introspective Skill

## What to build

Write `skills/introspective.json` for use in opencode and Claude Code. This skill is the on-demand mid/end-of-day check-in — it reads what you've actually written today and tells you how it maps to what you planned.

Skill flow:
1. Read today's Note from `~/notes/`
2. Read `daily-goals.md` (today's goals + subtasks)
3. Read `user-planner.md` (open Soft Tasks)
4. Surface: what's on track, what's drifting, what's unaddressed

## Acceptance criteria

- [ ] Skill is triggerable from opencode and Claude Code
- [ ] Skill reads today's Note (correct date-named file)
- [ ] Skill cross-references note content against Daily Goals subtasks
- [ ] Skill cross-references note content against open User Planner items
- [ ] Output clearly distinguishes on-track, drifting, and unaddressed items
- [ ] Skill handles the case where `daily-goals.md` is empty (Today's Goals Skill hasn't been run yet)

## Blocked by

- #3 (cleanup script must exist — introspective may call it if resolving planner items)
