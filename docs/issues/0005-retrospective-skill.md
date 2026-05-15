# #5 — Retrospective Skill

## What to build

Write `skills/retrospective.json` for use in opencode and Claude Code. This skill is the "looking back" session — it surfaces open Soft Tasks from the User Planner and finds new ones hiding in recent Notes.

Skill flow:
1. Read `user-planner.md` and ask the user about each open item — has it been done?
2. Scan the last 14 days of Notes in `~/notes/` and identify new Soft Tasks (action items in prose not yet in the planner)
3. Add any new Soft Tasks to `user-planner.md` with a reference to the source Note file
4. Call `scripts/cleanup_planner.py` at the end of the session to strip resolved items

User Planner entry format: `- [ ] <natural language description> — see ~/notes/<dated-file>.md`

## Acceptance criteria

- [ ] Skill is triggerable from opencode and Claude Code
- [ ] Skill reads and surfaces all open items in `user-planner.md` before scanning notes
- [ ] Skill correctly identifies Soft Tasks from note prose (not just explicit checkboxes)
- [ ] New Soft Tasks are written to `user-planner.md` with source file references
- [ ] `cleanup_planner.py` is called at the end of every session
- [ ] Skill does not duplicate planner items already present

## Blocked by

- #3 (cleanup script must exist before skill calls it)
