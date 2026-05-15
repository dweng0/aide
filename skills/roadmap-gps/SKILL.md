---
name: roadmap-gps
description: Creates and maintains per-project roadmaps at ~/.notes-context/roadmap/{name}.md using a Now/Next/Later horizon model. Use when the user wants to plan a project roadmap, update an existing roadmap, review project direction, or asks what to work on next.
---

# Roadmap GPS

Build and maintain a living project roadmap through structured grilling.

## Startup

1. **Infer the project** — check for `CONTEXT.md` in the current directory; use its `name` field. Otherwise use the directory name. Check whether `~/.notes-context/projects/{name}/roadmap.md` exists.
   - Match found → **Update flow**
   - No match → ask the user which project (or confirm a new one)
   - No roadmaps exist at all → tell the user to run `/project-start` first

2. **Require project context** — check for `~/.notes-context/projects/{name}/project-context.md`. If it does not exist, stop and tell the user to run `/project-start` for this project first.

3. **Load vocabulary** — read `project-context.md` for project name and static context. If `CONTEXT.md` exists in the current directory, read it too. Use both when asking questions and writing Deliverable names. Challenge fuzzy language against the glossary.

## Init flow — new project

Ask one question at a time:

1. Confirm the project name (read from `project-context.md`)
2. Confirm the end goal (read from `project-context.md`, or ask if not set)
3. Grill to surface Deliverables per horizon:
   - **Dependencies first**: "What needs to happen before anything else can move?" → Now candidates
   - **Queue**: "What's ready to start once Now is done?" → Next candidates
   - **Parking lot**: "What's on your mind but not urgent?" → Later candidates
   - Challenge each placement: "What breaks if this slips from Now to Next?" / "Is anything blocking this from starting today?"

## Update flow — existing project

1. Show current roadmap: Now items in full, count of Next / Later / Done.
2. Ask: "What's changed since you last updated this?"
3. Work through open items one at a time:
   - Now items: "Done, still in progress, or blocked?"
   - Blocked items: "Still blocked? What's the blocker?"
   - Then: "Anything new to add? Anything to promote from Next into Now?"

## Confirmation

Before writing, present a diff summary:

```
Changes to write:
  ✓ completed: Ship core skills
  → Now→Done: Ship core skills
  + added to Next: Calendar integration
  ⚠ blocked: Roadmap GPS skill (since 2026-05-12)
```

Ask: "Write these changes?" Only write on confirmation.

## File format

`~/.notes-context/projects/{name}/roadmap.md`

```markdown
<!-- Auto-generated and managed by: roadmap-gps. Dates are ISO 8601 (YYYY-MM-DD). -->

# Project Name

**End goal:** One-line statement of what done looks like.

## Now
- Active deliverable <!-- added:2026-05-01 started:2026-05-10 -->
- Blocked deliverable <!-- added:2026-05-01 started:2026-05-10 blocked:2026-05-12 -->

## Next
- Queued deliverable <!-- added:2026-05-01 -->

## Later
- Parked deliverable <!-- added:2026-05-01 -->

## Done
- Completed deliverable <!-- added:2026-03-01 started:2026-03-15 completed:2026-04-20 -->
```

Blocked Deliverables stay in Now — do not move them to a separate section.
