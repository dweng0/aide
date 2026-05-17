import subprocess
import sys
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "scripts" / "filter_emails.py"


def run(senders, filter_content=None, tmp_path=None):
    env = {}
    if filter_content is not None:
        context_dir = tmp_path / "context"
        context_dir.mkdir(exist_ok=True)
        (context_dir / "email-filter.md").write_text(filter_content)
        env["CONTEXT_DIR"] = str(context_dir)
    else:
        env["CONTEXT_DIR"] = str(tmp_path / "empty")
    return subprocess.run(
        [sys.executable, str(SCRIPT)] + senders,
        env=env,
        capture_output=True,
        text=True,
    )


def test_passes_clean_sender(tmp_path):
    result = run(["alice@example.com"], tmp_path=tmp_path)
    assert "alice@example.com" in result.stdout


def test_blocks_matching_partial_pattern(tmp_path):
    result = run(
        ["noreply@somecompany.com"],
        filter_content="- noreply@\n",
        tmp_path=tmp_path,
    )
    assert result.stdout.strip() == ""


def test_passes_non_matching_sender(tmp_path):
    result = run(
        ["alice@example.com"],
        filter_content="- noreply@\n",
        tmp_path=tmp_path,
    )
    assert "alice@example.com" in result.stdout


def test_case_insensitive_match(tmp_path):
    result = run(
        ["NoReply@Company.com"],
        filter_content="- noreply@\n",
        tmp_path=tmp_path,
    )
    assert result.stdout.strip() == ""


def test_ignores_domain_only_lines(tmp_path):
    # Lines without '@' are domain patterns handled by Gmail query — not partial patterns
    result = run(
        ["user@github.com"],
        filter_content="- github.com\n",
        tmp_path=tmp_path,
    )
    assert "user@github.com" in result.stdout


def test_multiple_senders_filtered_independently(tmp_path):
    result = run(
        ["alice@example.com", "noreply@corp.com", "bob@work.com"],
        filter_content="- noreply@\n",
        tmp_path=tmp_path,
    )
    lines = result.stdout.strip().splitlines()
    assert "alice@example.com" in lines
    assert "bob@work.com" in lines
    assert not any("noreply" in l for l in lines)


def test_no_filter_file_passes_all(tmp_path):
    result = run(
        ["alice@example.com", "noreply@corp.com"],
        tmp_path=tmp_path,
    )
    lines = result.stdout.strip().splitlines()
    assert "alice@example.com" in lines
    assert "noreply@corp.com" in lines


def test_no_senders_produces_no_output(tmp_path):
    result = run([], filter_content="- noreply@\n", tmp_path=tmp_path)
    assert result.stdout.strip() == ""
