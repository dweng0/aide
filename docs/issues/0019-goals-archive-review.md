# #19 — Remove goals-archive.md

**Labels:** cleanup · backlog

## Problem

`note_organizer.sh` archives the previous day's `daily-goals.md` into `goals-archive.md` by prepending a dated block each morning. Nothing reads this file back — it is write-only and grows indefinitely with no pruning.

The archive is also redundant: `~/notes/` already holds a daily note per day. If the user wants to know what they were working on last Thursday, the note for that day is the source of truth.

## Proposal

Remove the archiving step from `note_organizer.sh`. Daily Goals are a live document for today — once the day ends, `daily-goals.md` can simply be cleared.

## Acceptance criteria

- [ ] Remove the goals-archive block from `note_organizer.sh` (lines that write to `goals-archive.md`)
- [ ] Remove `goals-archive.md` from the files initialised in `install.sh`
- [ ] Remove `goals-archive.md` from the Aide Repo structure in `CONTEXT.md`
- [ ] Confirm no skill or script reads `goals-archive.md`
- [ ] Delete any existing `goals-archive.md` from `.notes-context/` (can be done manually or by install.sh migration step)

## Blocked by

None.
