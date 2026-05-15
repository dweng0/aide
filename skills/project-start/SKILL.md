---
name: project-start
description: One-time project setup skill. Captures project name, end goal, MVP, timelines, and stakeholders through a structured interview. Writes project-context.md and stakeholders.md to ~/.notes-context/projects/{name}/. Run this before using roadmap-gps on a new project.
---

# Project Start

Capture the static facts about a new project and write them to `~/.notes-context/projects/{name}/` so that `roadmap-gps` and other skills have a stable reference.

## Step 1 — Resolve the project name

1. Check for `CONTEXT.md` in the current directory. If it exists and has a `name:` field in its frontmatter, use that value as the project name.
2. If no `CONTEXT.md`, use the current directory name.
3. If neither is usable (e.g. directory is `~` or `/`), ask: "What should we call this project?"

## Step 2 — Check for existing context

Check whether `~/.notes-context/projects/{name}/project-context.md` already exists.

- **If it exists:** Tell the user — "This project already has context from a previous run (`~/.notes-context/projects/{name}/project-context.md`)." Show the existing end goal line so they know what was captured. Ask: "Do you want to update it?" If they say no, stop. If yes, continue with the interview — you will overwrite both files at the end.
- **If it does not exist:** Proceed directly to the interview.

## Step 3 — Interview

Ask one question at a time. Do not present a form or ask multiple questions in one message.

1. **End goal:** "What does done look like for this project? Give me a one-liner — 'Done when…'"
2. **MVP:** "What's the minimum version that would be useful? What can you cut without losing the point?"
3. **Timelines:** "Are there any key dates or milestones? Hard deadlines, soft targets, anything on the calendar?"
4. **Stakeholders:** "Who else is involved in this project? Give me one person at a time — I'll ask for name, role, and email."
   - For each person: ask name → role → email → "Anyone else?" Repeat until the user says no.
   - If the user says "no one else" or "that's it" at the start, record zero stakeholders and move on.

## Step 4 — Confirm before writing

Show a summary of what you captured:

```
Here's what I'll write to ~/.notes-context/projects/{name}/:

project-context.md
  Project: {name}
  End goal: {end goal}
  MVP: {mvp}
  Timelines: {timelines}

stakeholders.md
  - {name} · {role} · {email}
  - ...

Write these files?
```

Only proceed on confirmation.

## Step 5 — Write the files

Create `~/.notes-context/projects/{name}/` if it does not exist, then write both files.

### project-context.md format

```markdown
# {Project Name}

## End goal

{End goal statement}

## MVP

{MVP description}

## Timelines

{Timelines and key dates, or "No hard deadlines." if none given}
```

### stakeholders.md format

```markdown
# Stakeholders

| Name | Role | Email |
|------|------|-------|
| {name} | {role} | {email} |
```

If there are no stakeholders, write:

```markdown
# Stakeholders

No stakeholders recorded.
```

## Notes

- Do not modify `CONTEXT.md` in the repo — that is a repo-level file, not a project context file.
- Do not create a roadmap — that is `roadmap-gps`'s job.
- If the user wants to update a single field without re-running the full interview, remind them they can edit the file directly at `~/.notes-context/projects/{name}/project-context.md`.
