#!/usr/bin/env python3
"""Morning briefing script — fetches Gmail via IMAP."""
import imaplib
import email
import email.header
import email.utils
import os
import sys
import re
from datetime import datetime, timedelta
from pathlib import Path


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

def context_dir():
    return Path(os.environ.get("HOME", Path.home())) / ".notes-context"


def load_env():
    env_file = context_dir() / ".env"
    if not env_file.exists():
        return {}
    values = {}
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if "=" in line and not line.startswith("#"):
            key, _, val = line.partition("=")
            values[key.strip()] = val.strip()
    return values


# ---------------------------------------------------------------------------
# Gmail helpers
# ---------------------------------------------------------------------------

def load_blocklist(filter_path):
    """Return list of blocklist patterns from email-filter.md."""
    if not filter_path.exists():
        return []
    patterns = []
    for line in filter_path.read_text().splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("- "):
            patterns.append(stripped[2:].strip())
    return patterns


def sender_blocked(sender_address, patterns):
    """Return True if sender_address contains any blocklist pattern (case-insensitive)."""
    lower = sender_address.lower()
    return any(p.lower() in lower for p in patterns)


def decode_header_value(raw):
    """Decode an email header value to a plain string."""
    parts = email.header.decode_header(raw or "")
    decoded = []
    for part, charset in parts:
        if isinstance(part, bytes):
            decoded.append(part.decode(charset or "utf-8", errors="replace"))
        else:
            decoded.append(part)
    return "".join(decoded)


def extract_plain_text(msg):
    """Extract plain-text body from an email.Message, stripping HTML."""
    body = ""
    if msg.is_multipart():
        for part in msg.walk():
            if part.get_content_type() == "text/plain":
                payload = part.get_payload(decode=True)
                if payload:
                    body = payload.decode(part.get_content_charset() or "utf-8", errors="replace")
                    break
    else:
        payload = msg.get_payload(decode=True)
        if payload:
            body = payload.decode(msg.get_content_charset() or "utf-8", errors="replace")
    body = re.sub(r"<[^>]+>", " ", body)
    body = re.sub(r"\s+", " ", body).strip()
    return body


def format_email_entry(sender, subject, received, body):
    """Format a single email entry for emails.md."""
    truncated = body[:500]
    return (
        f"## From: {sender}\n"
        f"**Subject:** {subject}  \n"
        f"**Received:** {received}\n\n"
        f"{truncated}\n\n"
        f"---\n"
    )


def fetch_gmail(env):
    """Connect to Gmail via IMAP and return list of email dicts from last 24h."""
    address = env.get("GMAIL_ADDRESS", "")
    password = env.get("GMAIL_APP_PASSWORD", "")
    if not address or not password:
        return None

    print("Connecting to Gmail...")
    conn = imaplib.IMAP4_SSL("imap.gmail.com", 993)
    conn.login(address, password)
    conn.select("INBOX")

    since = (datetime.now() - timedelta(hours=24)).strftime("%d-%b-%Y")
    _, data = conn.search(None, f'(SINCE "{since}")')
    msg_ids = data[0].split() if data[0] else []
    print(f"Fetching emails from the last 24 hours... found {len(msg_ids)}")

    messages = []
    for mid in msg_ids:
        _, raw = conn.fetch(mid, "(RFC822)")
        for part in raw:
            if isinstance(part, tuple):
                msg = email.message_from_bytes(part[1])
                sender = decode_header_value(msg.get("From", ""))
                subject = decode_header_value(msg.get("Subject", ""))
                date_str = msg.get("Date", "")
                try:
                    dt = email.utils.parsedate_to_datetime(date_str)
                    received = dt.strftime("%Y-%m-%d %H:%M")
                except Exception:
                    received = date_str
                body = extract_plain_text(msg)
                messages.append({"sender": sender, "subject": subject, "received": received, "body": body})

    conn.logout()
    return messages


def run_gmail():
    env = load_env()
    if not env.get("GMAIL_APP_PASSWORD") or not env.get("GMAIL_ADDRESS"):
        print("GMAIL_ADDRESS or GMAIL_APP_PASSWORD not set. Run install.sh to configure credentials.")
        return

    briefing_dir = context_dir() / "daily-briefing"
    briefing_dir.mkdir(parents=True, exist_ok=True)
    filter_path = context_dir() / "email-filter.md"
    patterns = load_blocklist(filter_path)

    messages = fetch_gmail(env)
    if messages is None:
        print("GMAIL_ADDRESS or GMAIL_APP_PASSWORD not set. Run install.sh to configure credentials.")
        return

    before = len(messages)
    surviving = [m for m in messages if not sender_blocked(m["sender"], patterns)]
    filtered_out = before - len(surviving)
    print(f"Applying noise filter... {filtered_out} filtered out, {len(surviving)} remaining")

    output_path = briefing_dir / "emails.md"
    with output_path.open("w") as f:
        for m in surviving:
            f.write(format_email_entry(m["sender"], m["subject"], m["received"], m["body"]))

    print(f"Writing to ~/{output_path.relative_to(Path.home())}")
    print("Done.")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

SUBCOMMANDS = {"gmail": run_gmail}


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in SUBCOMMANDS:
        print("Usage: morning_briefing.py <gmail>")
        sys.exit(1)
    SUBCOMMANDS[sys.argv[1]]()


if __name__ == "__main__":
    main()
