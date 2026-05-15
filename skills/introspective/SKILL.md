---
name: introspective
description: On-demand mid/end-of-day check-in that reads what you've written today and maps it against your plan. Use when the user wants a progress check, end-of-day review, or asks how their day is going relative to their goals.
---

# Introspective

Run a read-only check-in that cross-references today's work against today's plan.

## Step 1 — Load today's context

Derive today's date in `DD-MM-YY` format. Read the following files:

- **Today's note**: `~/notes/DD-MM-YY.md` — what the user has actually written today. If the file does not exist, note that no note has been written yet and proceed with what's available.
- **Daily goals**: `~/.notes-context/daily-goals.md` — today's goals and subtask checkboxes. If the file is empty (Today's Goals Skill hasn't been run yet), note this and assess only against the User Planner.
- **User Planner**: `~/.notes-context/user-planner.md` — open Soft Tasks.

## Step 2 — Cross-reference

Compare the content of today's note against:

1. Each goal and `- [ ]` subtask in `daily-goals.md`
2. Each open `- [ ]` item in `user-planner.md`

Classify each item into one of three states:

- **On-track**: the note contains clear evidence of progress or completion
- **Drifting**: the note mentions the topic but work is incomplete or tangential
- **Unaddressed**: no mention in today's note at all

## Step 3 — Report

Present the assessment clearly, grouped by state:

```
## On-track
- …

## Drifting
- …

## Unaddressed
- …
```

Keep observations factual and brief. Do not suggest changes to any files — this skill is read-only.
