---
name: retrospective
description: Session that surfaces open Soft Tasks from the User Planner and finds new ones hiding in recent notes. Run in the morning before Today's Goals, or at end of day — either works. Use when the user wants to review open action items, scan recent notes for missed tasks, or run their morning or end-of-day retrospective.
---

# Retrospective

Run a structured retrospective session in three phases.

## Phase 1 — Review open planner items

Read `~/.notes-context/user-planner.md`. For each `- [ ]` line, ask the user: has this been done? If yes, check it off in the file (`- [x]`). If no, leave it.

Work through items one at a time. Do not batch them.

## Phase 2 — Scan notes for new Soft Tasks

**Determine the scan window.**
Read `~/.notes-context/manifest.md` and look for a `last_scanned:` line.

- **`last_scanned` present** — scan every note in `~/notes/` (files named `DD-MM-YY.md`) from that date through today, inclusive.
- **`last_scanned` absent** — first run: scan the last 14 days through today, inclusive.

For each note in the window, identify Soft Tasks: action items mentioned in prose that are not already present in `user-planner.md`. A Soft Task is anything that implies future action — a follow-up, a thing to try, a person to contact, a decision to make.

Do not add items that are already in `user-planner.md`. Compare against existing entries before appending.

## Phase 3 — Update the planner

For each new Soft Task found, append a line to `~/.notes-context/user-planner.md`:

```
- [ ] <natural language description> — see ~/notes/DD-MM-YY.md
```

Use the source note's filename in the reference.

## End of session

**1. Run cleanup.**
Call `cleanup_planner.py` to strip all `- [x]` lines from `user-planner.md`:

- Read `~/.notes-context/manifest.md` and extract the `cleanup_planner:` line to get the script path.
- Run: `python3 <path from manifest>`

**2. Update `last_scanned`.**
Write today's date into `manifest.md` as `last_scanned: YYYY-MM-DD`. If the line already exists, replace it; if not, append it:

```bash
python3 - <<'EOF'
import re, datetime, os
path = os.path.expanduser("~/.notes-context/manifest.md")
today = datetime.date.today().isoformat()
with open(path) as f:
    content = f.read()
if "last_scanned:" in content:
    content = re.sub(r"last_scanned:.*", f"last_scanned: {today}", content)
else:
    content += f"last_scanned: {today}\n"
with open(path, "w") as f:
    f.write(content)
EOF
```
