---
name: retrospective
description: Looking-back session that surfaces open Soft Tasks from the User Planner and finds new ones hiding in recent notes. Use when the user wants to review open action items, scan recent notes for missed tasks, or run their end-of-day/week retrospective.
---

# Retrospective

Run a structured retrospective session in three phases.

## Phase 1 — Review open planner items

Read `~/.notes-context/user-planner.md`. For each `- [ ]` line, ask the user: has this been done? If yes, check it off in the file (`- [x]`). If no, leave it.

Work through items one at a time. Do not batch them.

## Phase 2 — Scan recent notes for new Soft Tasks

Read every note file in `~/notes/` dated within the last 14 days (files named `DD-MM-YY.md`). Identify Soft Tasks: action items mentioned in prose that are not already present in `user-planner.md`. A Soft Task is anything that implies future action — a follow-up, a thing to try, a person to contact, a decision to make.

Do not add items that are already in `user-planner.md` (exact or near-duplicate). No duplicate entries.

## Phase 3 — Update the planner

For each new Soft Task found, append a line to `~/.notes-context/user-planner.md`:

```
- [ ] <natural language description> — see ~/notes/DD-MM-YY.md
```

Use the source note's filename in the reference.

## End of session

When the session is complete, call `cleanup_planner.py` to strip all `- [x]` lines from `user-planner.md`:

1. Read `~/.notes-context/manifest.md` and extract the `cleanup_planner:` line to get the script path.
2. Run: `python3 <path from manifest>`

If the `cleanup_planner:` line is missing from `manifest.md`, fall back to `AIDE_PLANNER` env var for the planner path and warn the user that `install.sh` should be re-run to register the script path.
