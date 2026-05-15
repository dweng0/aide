# ADR 0002 — Today's Goals Skill doubles as the morning briefing

**Status:** Accepted  
**Date:** 2026-05-15

## Context

The system has two layers that need bridging: daily task tracking (Notes, Daily Goals, User Planner) and project planning (Deliverables in Roadmap Horizons). Additionally, the user wants calendar events and important emails surfaced each morning before committing to project work.

`CONTEXT.md` lists both Claude Code and opencode as supported runtimes for Skill Sessions. Any solution must work identically in both.

### Skill structure: extend vs. split

Two structural options were considered:

1. **Extend Today's Goals** — add calendar, email, and Deliverable surfacing as the first three phases of the existing morning ritual, before the open "anything else?" question.
2. **New Morning Briefing skill** — a separate skill that reads calendar, email, and the Now horizon, then hands off to Today's Goals for the goal-setting drill-down.

### External data access: MCP vs. script

Two approaches for reading Gmail and Google Calendar were considered:

1. **Claude.ai MCP integrations** — Gmail and Calendar MCP tools are already wired into Claude Code sessions.
2. **Python scripts using standard protocols** — a `morning_briefing.py` script the skill invokes directly.

The MCP tools are specific to Claude Code's hosted environment and unavailable in opencode. Since opencode is a supported runtime, MCP cannot be the sole access path.

### Calendar auth: GCP OAuth vs. iCal feed

For calendar access specifically:

1. **GCP OAuth + Google Calendar API** — full read/write, but requires creating a GCP project, enabling APIs, and managing OAuth tokens.
2. **iCal feed** — Google Calendar exposes a secret `.ics` URL (Calendar Settings → "Secret address in iCal format"). Read-only. No GCP, no OAuth — the URL itself is the credential.

Today's Goals only needs to read the calendar. Write access is not required.

### Email auth: GCP OAuth vs. IMAP App Password

For Gmail access:

1. **GCP OAuth + Gmail API** — requires GCP project.
2. **IMAP + App Password** — Gmail supports IMAP with a 16-character App Password generated in Google Account Settings (requires 2-Step Verification). Uses Python's built-in `imaplib`. No GCP required.

## Decision

1. **Extend Today's Goals** rather than create a separate Morning Briefing skill.
2. **Script-based access** (`morning_briefing.py`) rather than MCP — runs identically in Claude Code and opencode.
3. **iCal feed** for calendar access — stored as `GCAL_ICAL_URL` in `.notes-context/.env`. Parsed with `icalendar` Python library.
4. **IMAP + App Password** for Gmail — stored as `GMAIL_APP_PASSWORD` in `.notes-context/.env`. Read via `imaplib`.
5. **Layered email filtering** — script applies a noise blocklist (configurable in `.notes-context/email-filter.md`) to exclude automated senders before writing pre-filtered results to `.notes-context/daily-briefing/`. The LLM then applies nuanced judgment (Stakeholder-first + action-implied) on what remains.
6. GCP OAuth deferred until write access is needed (e.g. LLM Planner scheduling meetings).

## Session order

Today's Goals runs in four phases:

1. Calendar — surface today's events as candidate goals
2. Email — surface pre-filtered emails; LLM applies Stakeholder + action-implied judgment
3. Deliverables — surface Now-horizon items from the active project's roadmap
4. Open drill-down — "anything else?"

User confirms each surfaced candidate before it becomes a checkbox in `daily-goals.md`.

## Consequences

- `install.sh` must prompt for `GCAL_ICAL_URL` and `GMAIL_APP_PASSWORD` and write them to `.notes-context/.env`. It must also guide the user through the one-time GCP project prerequisite... which is now not needed. Install is fully scriptable.
- `morning_briefing.py` requires `icalendar` as a pip dependency (`pip install icalendar`). `imaplib` is in the Python standard library.
- The Introspective Skill is unchanged — it compares the Note against Daily Goals and User Planner only.
- Roadmap GPS remains the sole path for marking Deliverables complete.
- If iCal or IMAP credentials are missing, Today's Goals skips those phases and proceeds rather than failing.
- If write access to Google Calendar is needed in future (e.g. LLM Planner scheduling), GCP OAuth will need to be introduced at that point.
