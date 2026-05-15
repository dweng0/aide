#!/usr/bin/env python3
import os
from pathlib import Path

repo_root = Path(__file__).parent.parent
planner = Path(os.environ.get("AIDE_PLANNER", repo_root / "user-planner.md"))

if not planner.exists():
    raise SystemExit(0)

lines = planner.read_text().splitlines(keepends=True)
kept = [l for l in lines if not l.startswith("- [x] ")]
planner.write_text("".join(kept))
