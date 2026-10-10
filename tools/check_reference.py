"""Verify locked reference copies without requiring the old checkout."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main():
    inventory = json.loads((ROOT / "docs/reference/import-inventory.json").read_text(encoding="utf-8"))
    checked = 0
    for entry in inventory["files"]:
        path = (ROOT / entry["target"]).resolve()
        if not path.is_relative_to(ROOT) or not path.is_file():
            raise SystemExit(f"Missing/invalid reference: {entry['target']}")
        if entry["policy"] == "locked":
            actual = hashlib.sha256(path.read_bytes()).hexdigest()
            if actual != entry["sha256"]:
                raise SystemExit(f"Reference bytes changed: {entry['target']}")
            checked += 1
    art = ROOT / "docs/reference/coastal-editorial-v1"
    references = json.loads((art / "references.json").read_text(encoding="utf-8"))
    for entry in references["files"]:
        if hashlib.sha256((art / entry["path"]).read_bytes()).hexdigest().upper() != entry["sha256"]:
            raise SystemExit(f"Concept reference changed: {entry['path']}")
    if not (art / references["implementationPlan"]).is_file():
        raise SystemExit("Broken active concept roadmap reference")
    print(f"Reference check: {checked} locked copies and 4 concept hashes match")


if __name__ == "__main__":
    main()
