# aide

A personal assistant layer for daily note-taking and goal tracking. It wires together a small set of shell scripts and Claude Code skills to help you open the right note file, track daily goals, and reflect across days.

## Prerequisites

- macOS
- [fish shell](https://fishshell.com)
- Python 3

## Install

```sh
git clone <repo-url> ~/projects/aide
chmod +x ~/projects/aide/install.sh
~/projects/aide/install.sh
```

Open a new terminal. You can now run `note_organizer.sh` by name.

## What the installer sets up

| What | Where | Purpose |
|------|-------|---------|
| Notes directory | `~/notes/` | Daily note files (`DD-MM-YY.md`) |
| Manifest | `~/.notes-context/manifest.md` | Index of all context files — read by skills |
| Recent files | `~/.notes-context/history_index.md` | Chronological list of note filenames |
| Planner | `~/.notes-context/user-planner.md` | Carry-forward tasks with checkboxes |
| Daily goals | `~/.notes-context/daily-goals.md` | Today's goals; appended to yesterday's note each morning then cleared |
| Projects dir | `~/.notes-context/projects/` | Per-project context and stakeholder files |
| Fish PATH | `~/.config/fish/conf.d/aide.fish` | Adds `aide/scripts/` to `$PATH` |

Running `install.sh` a second time is safe — it never overwrites existing files.

## Morning briefing

`/todays-goals` reads your Gmail and Google Calendar live via Claude's built-in MCP integrations — no credentials or setup needed.

To filter noisy senders from the email phase, edit `~/.notes-context/email-filter.md`. The installer seeds a default blocklist; add one pattern per line (plain-text substring match against the sender address).

## Scripts

| Script | What it does |
|--------|-------------|
| `note_organizer.sh` | Creates today's note, archives yesterday's goals, opens the file |
| `note_taker.sh` | Opens a note file in vim with context loaded |
| `weekly-notes.sh` | Summarises the week's notes |
| `cleanup_planner.py` | Removes checked (`- [x]`) items from `user-planner.md` |

## Skills

Skills live in `skills/` and are loaded into Claude Code or opencode. To install a skill into Claude Code, copy its folder into `~/.claude/skills/`.

### Daily rhythm

```
Morning
  1. /retrospective   ← optional, clears yesterday's backlog into the planner
  2. /todays-goals    ← sets today's goals from calendar, email, planner, roadmap

During the day
  3. /introspective   ← "how's my day going?" — checks progress against goals

Evening (optional)
  4. /retrospective   ← harvests today's note for soft tasks before you close out
```

### Skill reference

| Skill | Trigger | When to use |
|-------|---------|-------------|
| `todays-goals` | `/todays-goals` | Every morning. Pulls from your calendar, email, open planner items, and active project deliverables, then drills each confirmed goal into concrete subtasks. Writes `daily-goals.md`. |
| `retrospective` | `/retrospective` | Morning before Today's Goals, or end of day. Scans your notes since last run for action items you mentioned in passing, reviews open planner items so you can close out done ones, and cleans up the planner. Run it whenever the planner feels stale. |
| `introspective` | `/introspective` | Mid-day or end of day, on demand. Read-only — reads today's note against your Daily Goals and planner, and tells you what's on-track, drifting, or unaddressed. Use it when you want a progress check without committing to a full session. |
| `project-start` | `/project-start` | Once per new project. Captures name, end goal, MVP, timelines, and stakeholders. Run this before `roadmap-gps` — it creates the context files that the roadmap skill reads. |
| `roadmap-gps` | `/roadmap-gps` | When starting a project roadmap or revisiting it. Grills you on dependencies and urgency to place deliverables into Now / Next / Later horizons. Today's Goals reads your Now horizon each morning, so keep it current. |
