---
name: todays-goals
description: Morning ritual skill that combines an external briefing with structured goal-setting. Runs in four phases — calendar, email, deliverables, then open drill-down. Use when the user wants to set goals for the day, do their morning planning session, or write their daily goals.
---

# Today's Goals

Run a structured session in four phases. Each phase surfaces candidates; the user confirms each one before it enters the drill-down. Write results to `~/.notes-context/daily-goals.md`.

---

## Phase 1 — Calendar

Use the Google Calendar MCP tool to list today's events. If authentication is required, complete it before continuing. If the tool is unavailable or returns no events, skip this phase silently — do not mention it to the user.

If there are events, summarise them naturally:

> "You have 3 events today: a 9am standup, a 2pm planning sync, and a 4:30pm 1:1. Do any of these need prep work as a goal?"

For each event the user confirms, run the drill-down (Phase 4 questions) and write the result to `daily-goals.md`.

---

## Phase 2 — Email

Read `~/.notes-context/daily-briefing/emails.md`.

If the file is absent or empty, skip this phase silently — do not mention it to the user.

For each email entry, apply LLM judgment to decide whether to surface it:

- **Always surface**: emails from senders whose name or address appears in any `~/.notes-context/projects/*/stakeholders.md`
- **Surface if action-implied**: email content implies the user needs to reply, decide, or send something
- **Skip**: everything else (newsletters, notifications, automated messages)

Present surfaced emails one at a time. For each, ask: "Want to add a goal for this?" If yes, run the drill-down and write to `daily-goals.md`.

---

## Phase 3 — Deliverables

Check `~/.notes-context/projects/*/roadmap.md` for projects that have a roadmap file.

- **No projects with a roadmap**: skip this phase silently, no message to user.
- **One project with a roadmap**: use it without asking.
- **Multiple projects with roadmaps**: ask "Which project are you focusing on today?" and use the chosen one.

From the chosen `roadmap.md`, extract Deliverables under the `## Now` section that are **not blocked**. A blocked Deliverable has a `blocked:` date in a trailing HTML comment (e.g. `<!-- blocked:2026-05-12 -->`). Do not surface blocked items.

Present the active Now-horizon deliverables:

> "Your Now horizon for [project] has 2 active deliverables: 'Ship core skills' and 'Write installer README'. Are you working on any of these today?"

For each the user confirms, run the drill-down and write `## Deliverable name` + `- [ ]` subtasks to `daily-goals.md`.

`roadmap.md` is never modified by this skill. Roadmap GPS is the sole path for marking Deliverables complete.

---

## Phase 4 — Open drill-down

Ask: "Anything else you want to achieve today?"

For each goal stated:

1. Ask at least one follow-up question to surface concrete subtasks:
   - "What does done look like for that?"
   - "Any blockers or dependencies?"
   - "Is there a specific first step?"

2. Use the answers to form `- [ ]` subtasks. Keep subtasks action-oriented and completable within the day.

---

## Writing to daily-goals.md

Write results to `~/.notes-context/daily-goals.md`. Format:

```
## Goal name
- [ ] Subtask one
- [ ] Subtask two
```

If the file already contains goals from an earlier session today, **append** new goals rather than overwriting. Do not duplicate any `##` heading already present in the file.

---

## Notes

- Do not modify `user-planner.md` — that is the Retrospective Skill's concern.
- Do not read or reference previous days' notes — focus is on today only.
- `daily-briefing/calendar.md` and `daily-briefing/emails.md` are read-only inputs — never write to them.
