# #12 — Project-scoped User Planner

**Labels:** enhancement · ready-for-agent

## Problem

All Soft Tasks from all projects accumulate in a single flat `user-planner.md` with no project tag or grouping. As the number of active projects grows, the Retrospective Skill works through an undifferentiated list — there is no way to focus a session on one project, or to see at a glance which tasks belong to which project.

## What to build

Add an optional project tag to each Soft Task entry in `user-planner.md`, and update the Retrospective Skill to group by project when displaying items.

### Entry format change

Current:
```
- [ ] Follow up with Mike about API upgrade — see ~/notes/15-05-26.md
```

Proposed:
```
- [ ] Follow up with Mike about API upgrade — see ~/notes/15-05-26.md [project:aide]
```

The `[project:name]` tag is appended at the end of the line. It is optional — untagged tasks remain valid and are grouped under **Untagged** during the Retrospective.

### Retrospective Skill changes

When displaying planner items in Phase 1, group by project tag:

```
## aide
- [ ] Follow up with Mike about API upgrade
- [ ] Write SKILL.md for introspective

## Untagged
- [ ] Check on gym membership renewal
```

When inferring new Soft Tasks from Notes in Phase 2, attempt to infer a project tag from the Note's content or from which project directory was active. If no project can be inferred, leave the tag absent.

### Introspective Skill changes

No change required — the Introspective Skill reads the whole planner and it works fine unfiltered for a single-day check-in.

## Acceptance criteria

- [ ] New Soft Tasks added by the Retrospective Skill include a `[project:name]` tag when a project can be inferred
- [ ] Phase 1 of the Retrospective groups items by project tag before presenting them
- [ ] Untagged tasks are presented last, under an **Untagged** heading
- [ ] `cleanup_planner.py` preserves the `[project:name]` tag when stripping `- [x]` lines (i.e. only removes completed lines, does not mangle remaining ones)
- [ ] Existing untagged entries in `user-planner.md` continue to work without migration

## Out of scope

- Filtering the Retrospective to a single project (future)
- Project-scoped planners as separate files (future — keep one file for now)
- Changing the Introspective Skill

## Blocked by

None.

---

> *This issue was created during a gap analysis session.*
