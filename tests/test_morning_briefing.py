"""Tests for morning_briefing.py — Gmail (IMAP) fetch."""
import subprocess
import sys
from pathlib import Path
from datetime import date, timedelta

SCRIPT = Path(__file__).parent.parent / "scripts" / "morning_briefing.py"


def run_script(*args, env=None):
    return subprocess.run(
        [sys.executable, str(SCRIPT)] + list(args),
        env=env,
        capture_output=True,
        text=True,
    )


def _load_mod():
    from importlib.util import spec_from_file_location, module_from_spec
    spec = spec_from_file_location("morning_briefing", SCRIPT)
    mod = module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


# ---------------------------------------------------------------------------
# Gmail — missing credentials
# ---------------------------------------------------------------------------

class TestGmailMissingCredentials:
    def test_exits_zero_when_env_missing(self, tmp_path):
        result = run_script("gmail", env={"HOME": str(tmp_path)})
        assert result.returncode == 0

    def test_prints_message_when_env_missing(self, tmp_path):
        result = run_script("gmail", env={"HOME": str(tmp_path)})
        assert "GMAIL_APP_PASSWORD" in result.stdout or "credential" in result.stdout.lower()

    def test_does_not_write_emails_md_when_credentials_missing(self, tmp_path):
        context_dir = tmp_path / ".notes-context"
        context_dir.mkdir()
        run_script("gmail", env={"HOME": str(tmp_path)})
        assert not (context_dir / "daily-briefing" / "emails.md").exists()


# ---------------------------------------------------------------------------
# Gmail — noise filter
# ---------------------------------------------------------------------------

class TestGmailNoiseFilter:
    def test_filters_noreply_sender(self):
        mod = _load_mod()
        patterns = ["noreply@", "github.com"]
        assert mod.sender_blocked("noreply@example.com", patterns)
        assert mod.sender_blocked("bot@github.com", patterns)
        assert not mod.sender_blocked("alice@example.com", patterns)

    def test_case_insensitive_match(self):
        mod = _load_mod()
        assert mod.sender_blocked("NOREPLY@example.com", ["NoReply@"])

    def test_load_blocklist_skips_headings_and_blanks(self, tmp_path):
        mod = _load_mod()
        filter_file = tmp_path / "email-filter.md"
        filter_file.write_text(
            "# Email noise blocklist\n\n- noreply@\n- github.com\n\n## Section\n"
        )
        assert mod.load_blocklist(filter_file) == ["noreply@", "github.com"]


# ---------------------------------------------------------------------------
# Gmail — output format
# ---------------------------------------------------------------------------

class TestGmailOutputFormat:
    def test_format_email_entry(self):
        mod = _load_mod()
        entry = mod.format_email_entry(
            sender="Jane Smith <jane@example.com>",
            subject="Q2 planning sync",
            received="2026-05-15 08:32",
            body="Hello there, this is the email body.",
        )
        assert "## From: Jane Smith <jane@example.com>" in entry
        assert "**Subject:** Q2 planning sync" in entry
        assert "**Received:** 2026-05-15 08:32" in entry
        assert "Hello there" in entry
        assert "---" in entry

    def test_body_truncated_at_500_chars(self):
        mod = _load_mod()
        entry = mod.format_email_entry("a@b.com", "sub", "2026-05-15 08:00", "x" * 600)
        body_part = entry.split("\n\n", 2)[-1]
        assert len(body_part.rstrip("\n---").strip()) <= 510


# ---------------------------------------------------------------------------
# CLI subcommand routing
# ---------------------------------------------------------------------------

class TestCLISubcommands:
    def test_unknown_subcommand_exits_nonzero(self, tmp_path):
        result = run_script("unknown", env={"HOME": str(tmp_path)})
        assert result.returncode != 0

    def test_no_args_prints_usage(self, tmp_path):
        result = run_script(env={"HOME": str(tmp_path)})
        assert result.returncode != 0
        assert "gmail" in result.stdout.lower() or "usage" in result.stdout.lower()

    def test_calendar_subcommand_removed(self, tmp_path):
        result = run_script("calendar", env={"HOME": str(tmp_path)})
        assert result.returncode != 0
