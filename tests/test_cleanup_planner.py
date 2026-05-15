import subprocess
import sys
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "scripts" / "cleanup_planner.py"


def run_script(planner_path):
    return subprocess.run(
        [sys.executable, str(SCRIPT)],
        env={"AIDE_PLANNER": str(planner_path)},
        capture_output=True,
        text=True,
    )


def test_removes_checked_lines(tmp_path):
    planner = tmp_path / "user-planner.md"
    planner.write_text(
        "- [x] completed task — see ~/notes/15-05-26.md\n"
        "- [ ] open task — see ~/notes/15-05-26.md\n"
    )
    result = run_script(planner)
    assert result.returncode == 0
    lines = planner.read_text().splitlines()
    assert lines == ["- [ ] open task — see ~/notes/15-05-26.md"]


def test_preserves_headings_and_blank_lines(tmp_path):
    planner = tmp_path / "user-planner.md"
    content = "# Planner\n\n- [x] done\n- [ ] keep\n\n## Section\n"
    planner.write_text(content)
    run_script(planner)
    assert planner.read_text() == "# Planner\n\n- [ ] keep\n\n## Section\n"


def test_noop_no_checked_items(tmp_path):
    planner = tmp_path / "user-planner.md"
    content = "- [ ] still open\n- [ ] also open\n"
    planner.write_text(content)
    run_script(planner)
    assert planner.read_text() == content


def test_noop_empty_file(tmp_path):
    planner = tmp_path / "user-planner.md"
    planner.write_text("")
    result = run_script(planner)
    assert result.returncode == 0
    assert planner.read_text() == ""


def test_noop_missing_file(tmp_path):
    planner = tmp_path / "user-planner.md"
    result = run_script(planner)
    assert result.returncode == 0
    assert not planner.exists()
