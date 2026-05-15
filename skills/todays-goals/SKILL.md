---
name: todays-goals
description: Morning ritual skill that converts a loose statement of intent into a structured daily plan. Use when the user wants to set goals for the day, do their morning planning session, or write their daily goals.
---

# Today's Goals

Run a structured drill-down that turns loose intentions into a concrete, checkable plan for the day.

## Step 1 — Ask for goals

Ask: "What do you want to achieve today?"

Let the user state as many goals as they like before moving on.

## Step 2 — Sharpen each goal

For each goal stated, ask at least one follow-up question to surface concrete subtasks:

- "What does done look like for that?"
- "Any blockers or dependencies?"
- "Is there a specific first step?"

Use the answers to form `- [ ]` subtasks. Keep subtasks action-oriented and completable within the day.

## Step 3 — Write to daily-goals.md

Write the results to `~/.notes-context/daily-goals.md`. Format:

```
## Goal name
- [ ] Subtask one
- [ ] Subtask two
```

If the file already contains goals from an earlier session today, **append** new goals rather than overwriting. Do not duplicate any `##` heading already present in the file.

Handle multiple goals in a single session — repeat the drill-down for each goal before writing.

## Notes

- Do not modify `user-planner.md` — that is the Retrospective Skill's concern.
- Do not read or reference previous days' notes — focus is on today only.
