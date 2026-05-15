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
| Daily goals | `~/.notes-context/daily-goals.md` | Today's goals, reset each morning |
| Goals archive | `~/.notes-context/goals-archive.md` | Archived goals with date headers |
| Projects dir | `~/.notes-context/projects/` | Per-project context and stakeholder files |
| Fish PATH | `~/.config/fish/conf.d/aide.fish` | Adds `aide/scripts/` to `$PATH` |

Running `install.sh` a second time is safe — it never overwrites existing files.

## Morning briefing setup

`morning_briefing.py` fetches your Gmail and Google Calendar before you run `/todays-goals`. The installer will prompt for two credentials.

### Gmail (IMAP)

1. **Enable IMAP** — Gmail → Settings (gear) → See all settings → Forwarding and POP/IMAP → IMAP access → **Enable IMAP** → Save
2. **Create an App Password** — Google Account → Security → 2-Step Verification (must be enabled) → scroll to bottom → **App passwords** → name it anything (e.g. `aide`) → Create
3. Copy the 16-character password — that's your `GMAIL_APP_PASSWORD`

### Google Calendar

Calendar events are fetched live via the Google Calendar MCP integration built into Claude Code and opencode — no credentials or setup needed. The `/todays-goals` skill calls it directly during the session.

Once you have your Gmail credentials, run `install.sh` — it will prompt for them and write them to `~/.notes-context/.env`. Run `morning_briefing.py gmail` before starting `/todays-goals` each morning.

## Scripts

| Script | What it does |
|--------|-------------|
| `note_organizer.sh` | Creates today's note, archives yesterday's goals, opens the file |
| `note_taker.sh` | Opens a note file in vim with context loaded |
| `weekly-notes.sh` | Summarises the week's notes |
| `cleanup_planner.py` | Removes checked (`- [x]`) items from `user-planner.md` |
| `morning_briefing.py gmail` | Fetches last 24h of Gmail, filters noise, writes `daily-briefing/emails.md` |

## Skills

Skills live in `skills/` and are loaded into Claude Code or opencode. To install a skill into Claude Code, copy its folder into `~/.claude/skills/`.

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `todays-goals` | `/todays-goals` | Morning ritual. Asks what you want to achieve today, drills down to sharpen each goal into concrete subtasks, and writes them to `daily-goals.md`. |
| `introspective` | `/introspective` | On-demand mid/end-of-day check-in. Reads today's note and maps it against your Daily Goals and open Soft Tasks — surfaces what's on-track, drifting, or unaddressed. |
| `retrospective` | `/retrospective` | Looking-back session. Reviews open items in the User Planner, scans the last 14 days of notes for new Soft Tasks, and cleans up resolved items. |
| `project-start` | `/project-start` | One-time project setup. Captures project name, end goal, MVP, timelines, and stakeholders. Writes `project-context.md` and `stakeholders.md` to `~/.notes-context/projects/{name}/`. Run this before using `roadmap-gps` on a new project. |
| `roadmap-gps` | `/roadmap-gps` | Living roadmap manager. Grills you on dependencies and urgency to place Deliverables into Now / Next / Later horizons. Updates the roadmap after confirmation. Requires `project-start` to have been run first. |
