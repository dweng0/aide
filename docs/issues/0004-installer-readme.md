# #4 — Installer + README

## What to build

Write `install.sh` and `README.md`. The installer is the single command a user runs on a fresh machine to get `aide` fully operational. It must be idempotent — safe to run multiple times.

`install.sh` does:
1. Creates `~/notes/` if it doesn't exist
2. Initialises each `.notes-context/` file (manifest.md, history_index.md, user-planner.md, daily-goals.md, goals-archive.md) if they don't already exist
3. Writes `~/.config/fish/conf.d/aide.fish` to add `aide/scripts/` to `$PATH`

`README.md` documents:
- What `aide` is
- Install steps: clone the repo, run `./install.sh`, open a new terminal
- What the installer sets up

## Acceptance criteria

- [ ] `install.sh` is executable and idempotent
- [ ] Running it on a fresh machine creates `~/notes/`, all `.notes-context/` files, and the fish PATH file
- [ ] Running it a second time does not overwrite existing `.notes-context/` files
- [ ] `README.md` covers what aide is, install steps, and what the installer does
- [ ] A new terminal session after install can run `note_organizer.sh` by name (it's on PATH)

## Blocked by

- #2 (scripts must exist before installer wires them up)
