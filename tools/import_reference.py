"""One-time, read-only import from the independent JavaScript reference checkout."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent.parent
DOCS = [
    "RULES.md", "GAMEPLAY-SANDBOX.md", "game_story_bible.md",
    "GAMEPLAY-ROUTE-PLAYTEST-2026-10-05.md",
    "gameplay-route-playtest-2026-10-05.json",
    "gameplay-baseline.json", "sandbox-baseline.json",
]
ART = ["01-dialogue.png", "02-menu.png", "03-hud-map.png", "04-dossier.png", "prompts.json"]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    args = parser.parse_args()
    source = args.source.resolve()
    if source == ROOT or not (source / "content/locales/vi.js").is_file():
        raise SystemExit("Expected a separate hai-vong reference checkout")
    pairs = [(f"docs/{name}", f"docs/reference/hai-vong/{name}") for name in DOCS]
    pairs += [(f"docs/ui-concepts/coastal-editorial-v1/{name}",
               f"docs/reference/coastal-editorial-v1/{name}") for name in ART]
    pairs += [
        ("docs/ui-concepts/coastal-editorial-v1/references.json",
         "docs/reference/coastal-editorial-v1/references.source.json"),
        ("docs/ui-specs/coastal-replica/ui-scope.json", "docs/reference/specs/ui-scope.source.json"),
        ("docs/ui-specs/coastal-replica/layouts.json", "docs/reference/specs/layouts.source.json"),
    ]
    for name in ["source-serif-4.ttf", "OFL.txt", "METADATA.pb"]:
        pairs.append((f"assets/fonts/coastal-replica/sourceserif4/{name}",
                      f"assets/fonts/source_serif_4/{name}"))
    generated = ["content/locales/vi.json", "docs/reference/import-inventory.json",
                 "docs/reference/coastal-editorial-v1/references.json"]
    for relative in [target for _, target in pairs] + generated:
        if (ROOT / relative).exists():
            raise SystemExit(f"Refusing to overwrite existing import: {relative}")
    for relative, _ in pairs:
        if not (source / relative).is_file():
            raise SystemExit(f"Missing source file: {relative}")
    script = (
        "import {pathToFileURL} from 'node:url';"
        "const {default:catalog}=await import(pathToFileURL(process.argv[1]).href);"
        "process.stdout.write(JSON.stringify(catalog));"
    )
    node = shutil.which("node")
    if not node:
        raise SystemExit("Node is required only for this one-time ES module import")
    catalog = json.loads(subprocess.check_output(
        [node, "--input-type=module", "-e", script, str(source / "content/locales/vi.js")],
        text=True, encoding="utf-8", timeout=30,
    ))
    catalog["ui.common.quit"] = "Thoát"
    entries = []
    for relative, target in pairs:
        original, copied = source / relative, ROOT / target
        copied.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, copied)
        expected = digest(original)
        if digest(copied) != expected:
            raise SystemExit(f"Copy integrity failure: {target}")
        entries.append({"source": relative, "target": target, "sha256": expected, "policy": "locked"})
    locale = ROOT / "content/locales/vi.json"
    locale.parent.mkdir(parents=True, exist_ok=True)
    locale.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    entries.append({"source": "content/locales/vi.js", "target": "content/locales/vi.json",
                    "source_sha256": digest(source / "content/locales/vi.js"),
                    "target_sha256_at_import": digest(locale), "policy": "editable",
                    "adaptation": "ES module to JSON; add ui.common.quit"})
    art_path = ROOT / "docs/reference/coastal-editorial-v1"
    art = json.loads((art_path / "references.source.json").read_text(encoding="utf-8"))
    art["implementationPlan"] = "../../migration/README.md"
    art.pop("historicalImplementationPlan", None)
    art["sourceSnapshot"] = "references.source.json"
    (art_path / "references.json").write_text(
        json.dumps(art, ensure_ascii=False, indent=2) + "\n", encoding="utf-8",
    )
    commit = subprocess.check_output(["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
    inventory = {"version": 1, "source_project": "hai-vong", "source_commit": commit,
                 "source_was_clean": not subprocess.check_output(
                     ["git", "-C", str(source), "status", "--porcelain"], text=True).strip(),
                 "files": entries}
    (ROOT / "docs/reference/import-inventory.json").write_text(
        json.dumps(inventory, ensure_ascii=False, indent=2) + "\n", encoding="utf-8",
    )
    print(f"Imported {len(pairs)} byte-verified references and {len(catalog)} catalog entries")


if __name__ == "__main__":
    main()
