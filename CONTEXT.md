---
name: Aide
description: Domain glossary for the proactive note-taking and task intelligence system
---

## Glossary

### Note
A free-form, un-opinionated prose file in `~/notes/`, one per day, named by date (e.g., `15-05-26.md`). Created automatically by `note_organizer.sh`, which also appends the new filename to `history_index.md` at creation time. No required structure — the user writes whatever they want.


### Soft Task
An action item inferred by the LLM from Note prose; not explicitly written as a checkbox by the user. Example: the phrase "need to talk to Mike about the API upgrade" in a note becomes a Soft Task. Soft Tasks are written into `user-planner.md` by the LLM.

### User Planner
The LLM-maintained checklist of Soft Tasks (`.notes-context/user-planner.md`). Each entry is a markdown checkbox with a natural-language description and a reference to the source Note file. Tasks are checked off when the user confirms completion during a Skill Session. A cleanup script removes checked entries at the end of each Skill Session.

### Skill Session
A single run of either the Retrospective Skill or Introspective Skill inside the AI tool (opencode or Claude Code).

### Retrospective Skill
Run in the morning before the Today's Goals Skill, or at end of day — either works. Reads the User Planner and notes since the last run (falling back to 14 days on first run), surfaces open Soft Tasks for the user to close out, promotes newly found Soft Tasks from note prose into the User Planner, then runs the cleanup script to strip resolved items. After each run, records today's date as `last_scanned` in `manifest.md` so subsequent runs only process new notes.

### Introspective Skill
On-demand skill triggered from the AI tool (opencode or Claude Code). Reads today's Note and cross-references it against both the User Planner (open Soft Tasks) and the Daily Goals to assess whether the user is on track for the day. The user triggers it when they want a mid-day or end-of-day check-in — it is not tied to opening or writing a Note.

### Today's Goals Skill
Morning ritual skill that combines an external briefing with structured goal-setting. Runs in five phases, in order: (1) reads Google Calendar for today's events and surfaces candidates; (2) reads Gmail and surfaces emails from known Stakeholders or that imply action required, filtering automated noise; (3) surfaces open Soft Tasks from the User Planner that are actionable today; (4) surfaces Deliverables from the active project's Now horizon — if multiple projects have roadmaps, asks which project to focus on; (5) asks "anything else?". For each surfaced item the user confirms before it becomes a goal. Confirmed items are drilled into concrete subtasks using follow-up questions ("what does done look like today?", "any blockers?"). Writes results to `.notes-context/daily-goals.md` with the goal name as a heading and sharpened subtasks as checkbox items. The Introspective Skill uses this file as its reference for whether the user is on track. Roadmap GPS remains the sole path for marking Deliverables complete — ticking off daily subtasks does not update the roadmap.

### Daily Goals
A set of goals for the current day, each decomposed into measurable subtask checkboxes by the Today's Goals Skill. Stored in `.notes-context/daily-goals.md`. Format: goal name as `##` heading, subtasks as `- [ ]` items. When `note_organizer.sh` runs at the start of a new day, it appends the previous day's goals to yesterday's note file under a `## Goals` section (if that note exists), then clears `daily-goals.md`. Historical goals are therefore preserved inline in the daily note for that date in `~/notes/`. This co-location is intentional — the `## Goals` sections in daily notes are the planned data source for future goal-completion metrics (e.g. completion rates, goal frequency, carry-forward patterns). Do not remove or redirect this archiving step without a replacement metrics strategy.

### Aide Repo
The `aide` repository. Ships with scripts, skills, and an `install.sh`. Does not ship personal data — `.notes-context/` is fully gitignored. `install.sh` creates the `.notes-context/` directory and initialises empty files on first run. Structure:

```
aide/
├── .gitignore          # covers .notes-context/ entirely
├── install.sh
├── README.md
├── scripts/
│   ├── note_organizer.sh
│   ├── note_taker.sh
│   ├── weekly-notes.sh
│   └── cleanup_planner.py
├── skills/             # each skill has a .json trigger file and a SKILL.md directory
│   ├── todays-goals.json / todays-goals/SKILL.md
│   ├── introspective.json / introspective/SKILL.md
│   ├── retrospective.json / retrospective/SKILL.md
│   ├── project-start.json / project-start/SKILL.md
│   └── roadmap-gps.json / roadmap-gps/SKILL.md
├── tests/              # bats test suite
└── .notes-context/     # gitignored — created by install.sh
    ├── manifest.md
    ├── history_index.md
    ├── user-planner.md
    ├── daily-goals.md
    ├── email-filter.md
    └── projects/
```

### LLM Planner
Out of scope for current implementation. Reserved for future use — tasks the LLM itself needs to action on the user's behalf (as opposed to tasks for the user to do). Example: after the user confirms a meeting needs scheduling, the LLM Planner could hold a task to generate an `.ics` file and send it via an IMAP call (with user approval). Requires significant additional design before implementation.

### Deliverable
The unit of a Project Roadmap item. A concrete outcome with a clear "done when" condition. Carries four optional timestamps (ISO 8601): `added`, `started`, `blocked`, `completed`. Lives in exactly one Roadmap Horizon at any time. A Deliverable can be `blocked` — meaning work is stalled on an external dependency — while remaining in its current horizon.

### Roadmap Horizon
One of three planning buckets in a Project Roadmap: **Now** (actively in progress), **Next** (queued, dependencies met or nearly met), **Later** (parked or lower priority). Deliverables move between horizons during Roadmap GPS Skill sessions. A **Done** section archives completed Deliverables.

### Project Context
A per-project context file at `~/.notes-context/projects/{name}/project-context.md`, produced by the Project Start Skill. Captures the static, slow-changing facts about a project: name, end goal, MVP definition, and timelines. The project-level equivalent of the repo-level `CONTEXT.md`.

### Stakeholders
A per-project contact list at `~/.notes-context/projects/{name}/stakeholders.md`, produced by the Project Start Skill. Each entry records a person's name, role, and email. Used by the Today's Goals Skill to identify emails worth surfacing (any email from a known Stakeholder is surfaced regardless of content). Also reserved for future skills (email generation, calendar invites).

### Project Start Skill
One-time setup skill run at the beginning of a new project. Captures project name, end goal, MVP, timelines, and Stakeholders through a structured interview. Writes `project-context.md` and `stakeholders.md` into `~/.notes-context/projects/{name}/`. Required before Roadmap GPS Skill can run on a project.

### Project Roadmap
A per-project planning file at `~/.notes-context/projects/{name}/roadmap.md`, managed by the Roadmap GPS Skill. Contains three Roadmap Horizons (Now, Next, Later) and a Done archive, each holding a list of Deliverables. Metadata is encoded as inline HTML comments and is not intended for manual editing.

### Roadmap GPS Skill
Creates and maintains Project Roadmaps. Requires the Project Start Skill to have been run first — reads `project-context.md` for project name and vocabulary. Grills the user on dependencies first, then urgency, to place Deliverables into horizons. On subsequent runs, surfaces what has changed and updates the file after user confirmation. Infers the active project from the current working directory; asks if no match is found.
