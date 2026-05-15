# #7 — Today's Goals Skill

## What to build

Write `skills/todays-goals.json` for use in opencode and Claude Code. This is the morning ritual skill — it converts a loose statement of intent into a structured, measurable plan for the day.

Skill flow:
1. Ask "what do you want to achieve today?"
2. For each goal stated, ask follow-up questions to sharpen it into concrete subtasks (what does done look like? any dependencies? any blockers?)
3. Write results to `daily-goals.md` — goal name as `##` heading, sharpened subtasks as `- [ ]` checkboxes

Future: will also read the user's calendar to surface today's meetings and attendees before the drill-down (see `roadmap.md`).

## Acceptance criteria

- [ ] Skill is triggerable from opencode and Claude Code
- [ ] Skill asks at least one follow-up question per goal to sharpen subtasks
- [ ] Results are written to `daily-goals.md` in the correct format
- [ ] Running the skill a second time on the same day appends to (or replaces) the file cleanly — no duplicate headings
- [ ] Skill handles multiple goals in a single session

## Blocked by

None — can start immediately (#1 scaffold is done).
