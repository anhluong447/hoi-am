extends RefCounted
## Composition reads side-room content once per mount, validates it and injects
## plain config plus loaded textures; the room scene itself never reads files.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const VALIDATION = preload("res://src/shared/side_room_validation.gd")
const MANIFEST_PATH := "res://content/world2d/art_manifest_v1.json"
const TUNING_PATH := "res://content/world2d/tuning.json"
const PHASE_MAP_PATH := "res://content/world2d/phase_lighting.json"
const LIGHTING_DIR := "res://content/world2d/lighting/"


## Loads <rooms_path><room_id>.json and its shared world2d inputs, then prepares.
static func load_room(rooms_path: String, room_id: String) -> Dictionary:
	if not room_id.is_valid_identifier():
		return _failure("invalid_side_room_id")
	var room := LOADER.read_dictionary(rooms_path.path_join(room_id + ".json"))
	var manifest := LOADER.read_dictionary(MANIFEST_PATH)
	var tuning := LOADER.read_dictionary(TUNING_PATH)
	var phase_map := LOADER.read_dictionary(PHASE_MAP_PATH)
	if not room.ok or not manifest.ok or not tuning.ok or not phase_map.ok:
		return _failure("side_room_unreadable")
	if room.data.get("id") != room_id or not str(room.data.get("lighting_ref", "")).is_valid_identifier():
		return _failure("invalid_side_room")
	var lighting := LOADER.read_dictionary(LIGHTING_DIR + str(room.data.lighting_ref) + ".json")
	if not lighting.ok:
		return _failure("side_lighting_unreadable")
	return prepare(room.data, manifest.data, lighting.data, phase_map.data, tuning.data)


static func prepare(room: Dictionary, manifest: Dictionary, lighting: Dictionary, phase_map: Dictionary, tuning: Dictionary = {}) -> Dictionary:
	var errors: Array = []
	for checked: Dictionary in [VALIDATION.validate_manifest(manifest), VALIDATION.validate_room(room, manifest), VALIDATION.validate_lighting(lighting)]:
		errors.append_array(checked.errors)
	if not errors.is_empty():
		return {"ok": false, "error": {"code": "invalid_side_room", "errors": errors}}
	var config := room.duplicate(true)
	config.manifest = manifest.duplicate(true)
	config.tuning = tuning.duplicate(true)
	config.lighting = lighting.duplicate(true)
	config.phase_map = phase_map.duplicate(true)
	var textures: Dictionary = {}
	for item: Dictionary in room.layers + room.props:
		var asset: Dictionary = manifest.assets[item.art_ref]
		if asset.kind != "image" or textures.has(item.art_ref):
			continue
		var texture := load(asset.path) as Texture2D
		if not texture:
			return _failure("missing_side_texture")
		textures[item.art_ref] = texture
	return {"ok": true, "config": config, "textures": textures}


static func _failure(code: String) -> Dictionary:
	return {"ok": false, "error": {"code": code}}
