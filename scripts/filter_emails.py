#!/usr/bin/env python3
"""
Pre-filter email senders against partial patterns from email-filter.md.
Usage: filter_emails.py sender1@example.com sender2@example.com ...
Prints senders that do NOT match any partial pattern (lines containing '@').
"""
import os
import sys


def load_partial_patterns(filter_file):
    patterns = []
    try:
        with open(filter_file) as f:
            for line in f:
                line = line.strip()
                if line.startswith("- ") and "@" in line:
                    patterns.append(line[2:].lower())
    except FileNotFoundError:
        pass
    return patterns


def main():
    context_dir = os.environ.get("CONTEXT_DIR", os.path.expanduser("~/.notes-context"))
    filter_file = os.path.join(context_dir, "email-filter.md")
    patterns = load_partial_patterns(filter_file)

    for sender in sys.argv[1:]:
        if not any(p in sender.lower() for p in patterns):
            print(sender)


if __name__ == "__main__":
    main()
