# ADR 0003 — Today's Goals Skill uses MCP for external data access

**Status:** Accepted
**Date:** 2026-05-17
**Supersedes (partially):** ADR 0002 — the external data access decision only. ADR 0002's structural decisions (extend Today's Goals, layered email filtering, session phase order) remain accepted.

## Context

ADR 0002 decided to access Gmail and Google Calendar via a `morning_briefing.py` script (IMAP App Password + iCal feed) rather than MCP, on the grounds that MCP tools are unavailable in opencode.

After implementation began, this approach introduced friction that outweighed its benefits:

- `morning_briefing.py` required a separate manual step before each `/todays-goals` session.
- The iCal feed and IMAP App Password required credential setup and management (`~/.notes-context/.env`), adding install complexity with no clear payoff.
- The generated `daily-briefing/calendar.md` and `daily-briefing/emails.md` files were intermediate artifacts that added a layer of indirection without adding capability.
- The `icalendar` pip dependency is non-trivial (pure iCal parsing has known edge cases with recurring events, timezone handling, and VTIMEZONE blocks).

Meanwhile, Claude Code's built-in Gmail and Google Calendar MCP integrations proved sufficient for the Today's Goals use case: read-only, session-scoped access. The skill's email filtering logic (blocklist + Stakeholder-first judgment) works identically whether the data comes from a pre-fetched file or a live MCP query.

The opencode compatibility concern from ADR 0002 is deprioritised: the MCP integrations are the primary runtime, and opencode support is a future consideration.

## Decision

Use the Gmail MCP tool and Google Calendar MCP tool directly inside the Today's Goals Skill session, rather than a pre-run Python script.

- No `morning_briefing.py`.
- No `~/.notes-context/.env` with `GCAL_ICAL_URL` or `GMAIL_APP_PASSWORD`.
- No `~/.notes-context/daily-briefing/` intermediate files.
- `email-filter.md` remains — the skill builds the Gmail query from its blocklist patterns at session start.

## Consequences

- Install is simpler: no credential prompts, no pip dependency.
- The session is self-contained: no pre-run script required.
- opencode compatibility is not maintained for the calendar and email phases. If opencode support becomes a priority, a new ADR should revisit this decision.
- `daily-briefing/` is not created by `install.sh` — that scaffolding was removed.
- Issues #13 (credential setup), #14 (Gmail IMAP fetch), and #15 (iCal calendar fetch) are closed as wontfix.
