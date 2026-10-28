extends RefCounted

const MIGRATION = preload("res://src/domain/gameplay/state_migration.gd")


static func envelope(state: Dictionary, world: Dictionary, saved_at: String) -> Dictionary:
	return {"kind": "hoi-am-save", "envelope_version": 1, "ruleset": "gameplay", "content_version": 1,
		"saved_at": saved_at, "state": state.duplicate(true), "world": world.duplicate(true)}


static func decode(payload: Variant, pack: Dictionary, legacy_maps: Dictionary = {}) -> Dictionary:
	if not payload is Dictionary:
		return _invalid()
	var state: Variant
	var world: Variant = {}
	if payload.get("kind") == "hoi-am-save":
		if payload.get("envelope_version") != 1 or payload.get("ruleset") != "gameplay" or payload.get("content_version") != 1 or not payload.get("saved_at") is String:
			return _invalid()
		state = payload.get("state")
		world = payload.get("world")
		if not valid_world(world):
			return _invalid()
	elif payload.get("kind") == "press-gameplay-save":
		if payload.get("version") != 1 or payload.get("contentVersion") != 1 or payload.get("mode") not in ["pixel", "gameplay"]:
			return _invalid()
		state = payload.get("state")
		world = legacy_world(payload.get("world"), legacy_maps)
	elif payload.has("state"):
		state = payload.state
		world = legacy_world(payload.get("world"), legacy_maps)
	else:
		state = payload
		world = legacy_world(null, legacy_maps)
	if not state is Dictionary:
		return _invalid()
	var migrated := MIGRATION.migrate(state, pack)
	if not migrated.ok:
		return migrated
	return {"ok": true, "state": migrated.state, "world": world.duplicate(true)}


## v1: location/room plus optional HD-2D position. v2: exactly one of side-room
## x/facing or HD-2D position; carrying both is ambiguous and rejected.
static func valid_world(world: Variant) -> bool:
	if not world is Dictionary or not world.get("location_id") is String or not world.get("room_id") is String:
		return false
	if world.get("version") == 1:
		return not world.has("position") or _valid_position(world.position)
	if world.get("version") != 2 or world.has("x") == world.has("position"):
		return false
	if world.has("position"):
		return _valid_position(world.position) and not world.has("facing")
	return _finite(world.x) and _finite(world.get("facing")) and absf(float(world.facing)) == 1.0


static func legacy_world(world: Variant, mappings: Dictionary = {}) -> Dictionary:
	# Tile coordinates are renderer-specific; migrate location then use authored spawn.
	var map: String = str(world.get("mapId", world.get("map", "club"))) if world is Dictionary else "club"
	return {"version": 1, "location_id": mappings.get(map, "club"), "room_id": "legacy_tile"}


static func _valid_position(value: Variant) -> bool:
	if not value is Array or value.size() != 3:
		return false
	for item: Variant in value:
		if not _finite(item):
			return false
	return true


static func _finite(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(value)


static func _invalid() -> Dictionary:
	return {"ok": false, "error": {"code": "invalid_save_envelope", "text_key": "save.invalid"}}
