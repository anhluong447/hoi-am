"""Lexical architecture/content guard; engine execution remains a separate check."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
ALLOWED = {
    "shared": {"shared"},
    "domain": {"domain", "shared"},
    "application": {"application", "domain", "shared"},
    "infrastructure": {"infrastructure", "domain", "shared"},
    "presentation": {"presentation", "shared"},
    "world": {"world", "shared"},
    "bootstrap": {"bootstrap", "application", "domain", "infrastructure", "presentation", "shared", "world"},
}
LITERAL = re.compile(r'''(?:&|\^)?("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')''')
TEXT_PROPERTIES = "text|tooltip_text|placeholder_text|title|accessibility_name|accessibility_description"
# (source doc, link target) pairs that cannot resolve: byte-locked hai-vong
# imports (docs/design/SOURCES.json) link to source-repo files outside the
# imported subset. Every other link in docs/design/ is still checked below.
EXTERNAL_IMPORT_LINKS = {
    ("docs/design/first3/FIRST-THREE-DAYS.md", "ADDING-CONTENT.md"),
    ("docs/design/narrative/game_story_bible_v2.md", "../../history/narrative/game_story_bible.md"),
    ("docs/design/narrative/game_story_bible_v2.md", "../../history/narrative/BIBLE-CLB-BAO-CHI-PROPOSAL.md"),
}


def json_dictionary(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f"Duplicate JSON key: {key}")
            result[key] = value
        return result
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique)


def code_only(text):
    return re.sub(r"#[^\n]*", "", LITERAL.sub('""', text))


def main():
    issues = []
    def issue(path, message):
        issues.append(f"{path.relative_to(ROOT)}: {message}")
    catalog_path = ROOT / "content/locales/vi.json"
    catalog = json_dictionary(catalog_path)
    for key, value in catalog.items():
        if not isinstance(value, str) or not re.fullmatch(r"[a-zA-Z0-9_.-]+", key):
            issue(catalog_path, f"Invalid catalog entry: {key}")
    for path in sorted((ROOT / "content").rglob("*.json")):
        data = json_dictionary(path)
        def walk(value):
            if isinstance(value, dict):
                for key, item in value.items():
                    if key.endswith("_key") and (not isinstance(item, str) or item not in catalog):
                        issue(path, f"Unknown text key: {item}")
                    if key.endswith("_path") and isinstance(item, str) and item.startswith("res://"):
                        if not (ROOT / item[6:]).is_file():
                            issue(path, f"Missing content resource: {item}")
                    walk(item)
            elif isinstance(value, list):
                for item in value:
                    walk(item)
        if path != catalog_path:
            walk(data)
    scripts = sorted((ROOT / "src").rglob("*.gd"))
    classes = {}
    for path in scripts:
        match = re.search(r"(?m)^class_name\s+(\w+)", path.read_text(encoding="utf-8"))
        if match:
            classes[match[1]] = path.relative_to(ROOT).parts[1]
    for path in scripts:
        text = path.read_text(encoding="utf-8")
        layer = path.relative_to(ROOT).parts[1]
        allowed = ALLOWED.get(layer, set())
        if layer == "presentation" and "controllers" in path.relative_to(ROOT).parts[2:-1]:
            allowed = allowed | {"application", "domain"}
        if not allowed:
            issue(path, f"Unknown source layer: {layer}")
        for dependency in re.findall(r'res://src/([a-z_]+)/[^"\s]*', text):
            if dependency not in allowed:
                issue(path, f"Forbidden dependency: {layer} -> {dependency}")
        if layer == "domain":
            ruleset = path.relative_to(ROOT / "src/domain").parts[0]
            other = "formula_sandbox" if ruleset == "gameplay" else "gameplay" if ruleset == "formula_sandbox" else None
            if other and f"res://src/domain/{other}/" in text:
                issue(path, "Cross-ruleset domain import")
        code = code_only(text)
        for name, dependency in classes.items():
            if dependency not in allowed and re.search(rf"\b{re.escape(name)}\b", code):
                issue(path, f"Forbidden global class dependency: {name}")
        if layer in {"domain", "application", "shared"}:
            if not re.search(r"(?m)^extends RefCounted\s*$", text):
                issue(path, "Inner layer must extend RefCounted")
            forbidden = r"\b(Node\w*|SceneTree|FileAccess|DirAccess|ResourceLoader|DisplayServer|Input|InputMap|OS|Time|HTTP\w*|RandomNumberGenerator|randf|randi|get_tree)\b"
            if re.search(forbidden, code):
                issue(path, "Scene/I/O/input/clock/random API in inner layer")
        if len([line for line in text.splitlines() if line.strip()]) > 200:
            issue(path, "Runtime file exceeds 200 nonblank lines; split responsibilities")
        for literal in LITERAL.finditer(text):
            if any(ord(char) > 127 for char in literal.group()):
                issue(path, "Non-ASCII runtime literal; move display copy into catalog")
        direct_text = rf'''\b(?:{TEXT_PROPERTIES})\s*=\s*["'][^"'\n]+["']'''
        if re.search(direct_text, text):
            issue(path, "Direct player-facing text assignment")
        if re.search(r'''\bset_(?:text|tooltip_text|placeholder|title)\(\s*["'][^"']+["']''', text):
            issue(path, "Direct player-facing text setter")
    for extension in ("*.gd", "*.tscn", "*.tres"):
        for path in (ROOT / "src").rglob(extension):
            text = path.read_text(encoding="utf-8")
            for resource in re.findall(r'res://[^"\s)]+\.(?:gdshader|gd|tscn|tres|ttf|png|svg)(?=["\s)])', text):
                if not (ROOT / resource[6:]).is_file():
                    issue(path, f"Missing resource: {resource}")
            if path.suffix != ".gd" and re.search(
                rf'''(?m)^\s*(?:{TEXT_PROPERTIES})\s*=\s*"[^"\n]+"''', text
            ):
                issue(path, "Player-facing text in scene/resource")
    for path in (ROOT / "docs").rglob("*.md"):
        for target in re.findall(r"\]\(([^)]+)\)", path.read_text(encoding="utf-8")):
            target = target.split("#", 1)[0].strip("<>")
            if not target or re.match(r"[a-zA-Z]+://", target):
                continue
            if not (path.parent / target).exists():
                key = (path.relative_to(ROOT).as_posix(), target)
                if key in EXTERNAL_IMPORT_LINKS:
                    continue  # byte-locked import; target lives outside the imported subset
                issue(path, f"Broken documentation link: {target}")
    for message in issues:
        print(message)
    print(f"Architecture check: {len(issues)} issue(s); {len(scripts)} scripts; {len(catalog)} text entries")
    raise SystemExit(bool(issues))


if __name__ == "__main__":
    main()
