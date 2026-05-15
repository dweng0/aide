# #3 — Cleanup script

## What to build

Write `scripts/cleanup_planner.py`. When called, it reads `user-planner.md`, removes any line where the checkbox is checked (`[x]`), and rewrites the file in place. This is called automatically by skills at the end of every Skill Session.

## Acceptance criteria

- [ ] `cleanup_planner.py` exists in `aide/scripts/`
- [ ] Running the script removes all `- [x]` lines from `user-planner.md`
- [ ] Unchecked `- [ ]` lines are preserved exactly
- [ ] The script is a no-op if `user-planner.md` is empty or has no checked items
- [ ] The script resolves the path to `user-planner.md` relative to the `aide` repo (not hardcoded)

## Blocked by

None — can start immediately (#1 scaffold is done).
