# #11 — Roadmap GPS skill

**Labels:** enhancement · done

## What to build

Write the `roadmap-gps` skill (`skills/roadmap-gps.json` + `skills/roadmap-gps/SKILL.md`). This skill creates and maintains a living per-project roadmap at `~/.notes-context/projects/{name}/roadmap.md` using a Now / Next / Later horizon model.

Skill flows:
- **Init:** grills the user on dependencies then urgency to place Deliverables into horizons; confirms before writing
- **Update:** surfaces what has changed since the last session, walks open Now items, then asks for new additions; confirms a diff summary before writing

Requires `project-start` to have been run first — reads `project-context.md` for project name and vocabulary. Infers the active project from the current directory (`CONTEXT.md` name → directory name → ask).

## Acceptance criteria

- [x] `skills/roadmap-gps.json` exists with `name`, `description`, `triggers`, and `instructions` keys
- [x] Skill is triggerable by `/roadmap-gps` in Claude Code and opencode
- [x] Skill infers the active project from `CONTEXT.md` → directory name → ask
- [x] Skill gates on `project-context.md` existing; tells user to run `/project-start` if not
- [x] Init flow grills dependencies first, then urgency, to place Deliverables into Now / Next / Later
- [x] Update flow surfaces changes and walks open Now items before asking for additions
- [x] Diff summary shown and confirmed before any write
- [x] Deliverable timestamps encoded as inline HTML comments (ISO 8601)
- [x] Blocked Deliverables stay in Now (not moved to a separate section)

## Blocked by

- #8 — project-start skill (runtime dependency; roadmap-gps requires it to have been run first)
