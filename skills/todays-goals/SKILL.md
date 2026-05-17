---
name: todays-goals
description: Morning ritual skill that combines an external briefing with structured goal-setting. Runs in five phases — calendar, email, open planner items, deliverables, then open drill-down. Use when the user wants to set goals for the day, do their morning planning session, or write their daily goals.
---

# Today's Goals

Run a structured session in five phases. Each phase surfaces candidates; the user confirms each one before it enters the drill-down. Write results to `~/.notes-context/daily-goals.md`.

---

## Phase 1 — Calendar

Use the Google Calendar MCP tool to list today's events. If authentication is required, complete it before continuing. If the tool is unavailable or returns no events, skip this phase silently — do not mention it to the user.

If there are events, summarise them naturally:

> "You have 3 events today: a 9am standup, a 2pm planning sync, and a 4:30pm 1:1. Do any of these need prep work as a goal?"

For each event the user confirms, run the drill-down (Phase 5 questions) and write the result to `daily-goals.md`.

---

## Phase 2 — Email

**Step 1 — Build the query from the blocklist.**
Load `~/.notes-context/email-filter.md`. Extract every bullet line (lines starting with `- `). Split patterns into two groups:

- **Domain patterns** — no `@` character (e.g. `github.com`, `linkedin.com`). Convert each to a `-from:` clause.
- **Partial patterns** — contain `@` (e.g. `noreply@`, `notifications@`). These cannot be expressed as Gmail query clauses; hold them for Step 3.

Build the query:
```
in:inbox newer_than:1d -in:draft -from:domain1.com -from:domain2.com …
```

If `email-filter.md` is absent or has no domain patterns, use `in:inbox newer_than:1d -in:draft`.

**Step 2 — Fetch.**
Call the Gmail MCP tool with the constructed query. If the tool is unavailable or returns no results, skip this phase silently — do not mention it to the user.

**Step 3 — Apply partial-pattern filter.**
Extract the sender address from each fetched email. Read `filter_emails:` from `~/.notes-context/manifest.md` to get the script path. Pass all sender addresses as arguments:

```
python3 <filter_emails path> sender1@example.com sender2@example.com ...
```

The script prints only the senders that pass the partial-pattern filter (one per line). Discard emails whose sender does not appear in the output before reading their content.

**Step 4 — Relevance judgment.**
For each remaining email, decide whether to surface it:

- **Always surface**: emails from senders whose name or address appears in any `~/.notes-context/projects/*/stakeholders.md`
- **Surface if action-implied**: email content implies the user needs to reply, decide, or send something
- **Skip**: everything else (newsletters, notifications, automated messages)

Present surfaced emails one at a time. For each, ask: "Want to add a goal for this?" If yes, run the drill-down and write to `daily-goals.md`.

---

## Phase 3 — User Planner

Read `~/.notes-context/user-planner.md`. If the file is empty or does not exist, skip this phase silently.

For each open `- [ ]` item, apply judgment:

- **Surface**: items that could reasonably be actionable today (follow-ups, decisions, things to try)
- **Skip**: items that are clearly blocked on something external or long-horizon ("someday" tasks)

Present surfaced items one at a time:

> "You have an open item: 'Follow up with Mike about the API upgrade'. Want to make this a goal today?"

For each the user confirms, run the drill-down (Phase 5 questions) and write the result to `daily-goals.md`.

Do not modify `user-planner.md` — that is the Retrospective Skill's concern.

---

## Phase 4 — Deliverables

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

## Phase 5 — Open drill-down

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
- `email-filter.md` is a read-only input — never write to it.
