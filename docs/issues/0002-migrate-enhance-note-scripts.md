# #2 — Migrate + enhance note scripts

## What to build

Move the three note scripts from the `lifeline` repo into `aide/scripts/`. Enhance `note_organizer.sh` so it handles all day-boundary housekeeping automatically: appending the new Note filename to `history_index.md` on creation, archiving the previous day's `daily-goals.md` into `goals-archive.md` (with a date header, preserving checkbox state), and resetting `daily-goals.md` for the new day.

## Acceptance criteria

- [ ] `note_organizer.sh`, `note_taker.sh`, and `weekly-notes.sh` live in `aide/scripts/`
- [ ] Running `note_organizer.sh` on a new day appends the dated filename to `history_index.md`
- [ ] On a new day, previous `daily-goals.md` is archived into `goals-archive.md` with a `## YYYY-MM-DD` header and checkbox state preserved
- [ ] `daily-goals.md` is reset (empty) after archiving
- [ ] Running `note_organizer.sh` a second time on the same day does not duplicate the history entry or re-archive goals

## Blocked by

None — can start immediately (#1 scaffold is done).
