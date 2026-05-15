# ADR 0001 — Roadmap deliverable metadata encoded as inline HTML comments

**Status:** Accepted  
**Date:** 2026-05-15

## Context

Each Deliverable in a Project Roadmap needs four optional timestamps: `added`, `started`, `blocked`, `completed`. These timestamps are the basis for cycle-time metrics and blocked-duration tracking. The roadmap files are plain markdown, live in `~/.notes-context/roadmap/`, and are read both by the Roadmap GPS Skill and directly by the user in a text editor or terminal.

Three formats were considered:

1. **Inline HTML comments** — trailing comment on each deliverable line: `- Ship feature <!-- added:2026-05-01 started:2026-05-10 -->`
2. **Markdown tables** — explicit columns per horizon section: `| Deliverable | Added | Started | Blocked | Completed |`
3. **JSON sidecar file** — a `{name}.json` alongside each `{name}.md` holding all metadata

## Decision

Encode metadata as trailing HTML comments on each deliverable line.

## Reasons

- **Tables** are fragile to maintain programmatically (column alignment, row insertion) and visually noisy in raw files. They also couple the display format to the data structure in a way that's hard to evolve.
- **JSON sidecar** splits the source of truth across two files. A deliverable moved in the markdown without updating the JSON would silently lose its timestamps.
- **Inline HTML comments** are invisible in rendered markdown, trivially parseable, and keep the data co-located with the item it describes. The Roadmap GPS Skill owns all writes to these files, so alignment and formatting are not a manual burden.

A file header warns users the file is auto-managed:

```
<!-- Auto-generated and managed by: roadmap-gps. Dates are ISO 8601 (YYYY-MM-DD). -->
```

## Consequences

- The Roadmap GPS Skill is the sole writer of roadmap files. Manual edits to metadata comments are fragile and may be overwritten.
- Any future tooling that reads roadmap metadata must parse HTML comments rather than a structured format.
- Metrics scripts will need a simple regex parser — not a markdown parser.
