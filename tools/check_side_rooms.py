"""Validate side-scroll room content against the side_room_v1 schema plus
cross-file references (target rooms/spawns, image bytes) that need file I/O
and therefore cannot live in the pure GDScript validator."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLANES = {"sky", "far", "back", "mid", "foreground"}
PHASES = {"sang", "chieu", "toi", "dem"}


def _is_id(value):
    return isinstance(value, str) and value != ""


def _is_number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def _is_finite(value):
    return _is_number(value) and value == value and abs(value) != float("inf")


def _is_position(value):
    return isinstance(value, list) and len(value) == 2 and all(_is_finite(v) for v in value)


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def validate_structure(room, assets, errors, name):
    def fail(message):
        errors.append(f"{name}: {message}")

    if room.get("kind") != "side_room_v1":
        fail("kind must be side_room_v1")
    if not _is_id(room.get("id")):
        fail("id is required")
    bounds = room.get("bounds", {})
    bounds_valid = isinstance(bounds, dict) and _is_finite(bounds.get("min_x")) and _is_finite(bounds.get("max_x"))
    if not bounds_valid or bounds.get("min_x") >= bounds.get("max_x"):
        fail("bounds must have finite min_x < max_x")
        bounds_valid = False
    spawns = room.get("spawns", {})
    spawn_ids = set()
    if not isinstance(spawns, dict) or not spawns:
        fail("spawns requires at least one entry")
    else:
        for spawn_id, spawn in spawns.items():
            if not isinstance(spawn, dict) or not _is_finite(spawn.get("x")) or spawn.get("facing") not in (-1, 1):
                fail(f"spawn {spawn_id} is invalid")
                continue
            if bounds_valid and not (bounds["min_x"] <= spawn["x"] <= bounds["max_x"]):
                fail(f"spawn {spawn_id} x is outside bounds")
            spawn_ids.add(spawn_id)
    if not _is_id(room.get("default_spawn")) or room.get("default_spawn") not in spawn_ids:
        fail("default_spawn must reference an existing spawn")
    shared_ids = set()

    def claim(entry_id, label):
        if not _is_id(entry_id):
            fail(f"{label} missing id")
            return False
        if entry_id in shared_ids:
            fail(f"duplicate id across layers/props/doors/interactions: {entry_id}")
            return False
        shared_ids.add(entry_id)
        return True

    for layer in room.get("layers", []):
        if not claim(layer.get("id"), "layer"):
            continue
        if layer.get("plane") not in PLANES:
            fail(f"layer {layer['id']} has an unknown plane")
        if layer.get("art_ref") not in assets:
            fail(f"layer {layer['id']} art_ref is not in the manifest")
        if not _is_position(layer.get("position")):
            fail(f"layer {layer['id']} position must be two finite numbers")
    for prop in room.get("props", []):
        if not claim(prop.get("id"), "prop"):
            continue
        if prop.get("art_ref") not in assets:
            fail(f"prop {prop['id']} art_ref is not in the manifest")
        if not _is_position(prop.get("position")):
            fail(f"prop {prop['id']} position must be two finite numbers")
    for door in room.get("doors", []):
        if not claim(door.get("id"), "door"):
            continue
        if not _is_id(door.get("target_room")) or not _is_id(door.get("target_spawn")):
            fail(f"door {door['id']} requires target_room and target_spawn")
    for interaction in room.get("interactions", []):
        if not claim(interaction.get("id"), "interaction"):
            continue
        if not _is_id(interaction.get("label_key")):
            fail(f"interaction {interaction['id']} requires label_key")
    if not _is_id(room.get("lighting_ref")):
        fail("lighting_ref is required")
    return spawn_ids


def validate_image_bytes(assets, errors):
    for ref, asset in assets.items():
        if asset.get("kind") != "image":
            continue
        path = ROOT / asset["path"][6:]
        if not path.is_file():
            errors.append(f"manifest asset {ref}: missing image file {asset['path']}")
            continue
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        if digest != asset.get("sha256"):
            errors.append(f"manifest asset {ref}: sha256 mismatch for {asset['path']}")


def validate():
    rooms_dir = ROOT / "content/world2d/rooms"
    room_paths = sorted(rooms_dir.glob("*.json")) if rooms_dir.is_dir() else []
    if not room_paths:
        print("Side-room check: no rooms authored yet")
        return
    manifest_path = ROOT / "content/world2d/art_manifest_v1.json"
    manifest = read_json(manifest_path)
    assets = manifest.get("assets", {})
    errors = []
    validate_image_bytes(assets, errors)
    rooms = {}
    spawn_sets = {}
    for path in room_paths:
        room = read_json(path)
        name = path.relative_to(ROOT).as_posix()
        if not _is_id(room.get("id")) or room.get("id") in rooms:
            errors.append(f"{name}: id must be unique and non-empty")
            continue
        rooms[room["id"]] = room
        spawn_sets[room["id"]] = validate_structure(room, assets, errors, name)
    for room in rooms.values():
        for door in room.get("doors", []):
            target_room = door.get("target_room")
            if target_room not in rooms:
                errors.append(f"{room['id']}: door {door.get('id')} target_room '{target_room}' does not exist")
                continue
            if door.get("target_spawn") not in spawn_sets[target_room]:
                errors.append(
                    f"{room['id']}: door {door.get('id')} target_spawn '{door.get('target_spawn')}' "
                    f"not in room '{target_room}'"
                )
    if errors:
        raise AssertionError("; ".join(errors))
    print(f"Side-room check: {len(rooms)} rooms; doors and art references verified")


if __name__ == "__main__":
    validate()
