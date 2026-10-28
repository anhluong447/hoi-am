extends RefCounted
## Pure structural contracts for side-scroll rooms, art manifests and lighting
## presets; file loading, hashing and resource creation stay outside.
## Returns {"ok": bool, "errors": Array[String]} from every entry point.

const FIELDS = preload("res://src/shared/side_room_fields.gd")
const RULES = preload("res://src/shared/side_room_rules.gd")
const LIGHTING_PHASES := ["sang", "chieu", "toi", "dem"]
## Mirrors tools/check_side_rooms.py TUNING_KEYS: every key finite and > 0.
const TUNING_KEYS := ["max_speed", "accel_time", "decel_time", "stride", "bob", "camera_dead_zone", "camera_response", "actor_height", "actor_half_width"]


static func validate_manifest(manifest: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if not FIELDS.is_integer(manifest.get("schema_version")):
		errors.append("manifest.schema_version must be an int")
	var assets: Variant = manifest.get("assets")
	if not assets is Dictionary:
		errors.append("manifest.assets must be a dictionary")
	else:
		for ref: Variant in assets.keys():
			var asset: Variant = assets[ref]
			if not FIELDS.is_id(ref) or not asset is Dictionary:
				errors.append("manifest.assets has an invalid entry: %s" % str(ref))
				continue
			match asset.get("kind"):
				"greybox":
					if not FIELDS.is_color(asset.get("color")):
						errors.append("Asset %s greybox color must be #rrggbb" % ref)
					if not FIELDS.is_size(asset.get("size")):
						errors.append("Asset %s greybox size must be two positive numbers" % ref)
				"image":
					RULES.validate_image_asset(ref, asset, errors)
				_:
					errors.append("Asset %s has an unknown kind" % ref)
	return FIELDS.result(errors)


static func validate_lighting(preset: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if not FIELDS.is_integer(preset.get("schema_version")):
		errors.append("lighting.schema_version must be an int")
	var phases: Variant = preset.get("phases")
	if not phases is Dictionary:
		errors.append("lighting.phases must be a dictionary")
	else:
		for phase_id: String in LIGHTING_PHASES:
			if not phases.has(phase_id):
				errors.append("lighting.phases missing phase: %s" % phase_id)
				continue
			RULES.validate_phase(phase_id, phases[phase_id], errors)
	return FIELDS.result(errors)


static func validate_tuning(tuning: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	for key: String in TUNING_KEYS:
		if not FIELDS.is_positive_number(tuning.get(key)):
			errors.append("tuning.%s must be a finite number > 0" % key)
	return FIELDS.result(errors)


static func validate_room(room: Dictionary, manifest: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if room.get("kind") != "side_room_v1":
		errors.append("room.kind must be side_room_v1")
	if not FIELDS.is_id(room.get("id")):
		errors.append("room.id is required")
	if not FIELDS.is_id(room.get("location_id")):
		errors.append("room.location_id is required")
	if not FIELDS.is_id(room.get("title_key")):
		errors.append("room.title_key is required")
	if not FIELDS.is_positive_number(room.get("height")):
		errors.append("room.height must be positive")
	var bounds: Variant = room.get("bounds")
	var bounds_valid := bounds is Dictionary and FIELDS.is_finite_number(bounds.get("min_x")) and FIELDS.is_finite_number(bounds.get("max_x"))
	var min_x := 0.0
	var max_x := 0.0
	if not bounds_valid:
		errors.append("room.bounds requires finite min_x and max_x")
	else:
		min_x = float(bounds.min_x)
		max_x = float(bounds.max_x)
		if min_x >= max_x:
			errors.append("room.bounds.min_x must be less than max_x")
			bounds_valid = false
	if not FIELDS.is_finite_number(room.get("floor_y")):
		errors.append("room.floor_y must be a finite number")
	var spawn_ids := RULES.validate_spawns(room.get("spawns"), bounds_valid, min_x, max_x, errors)
	var default_spawn: Variant = room.get("default_spawn")
	if not FIELDS.is_id(default_spawn) or not spawn_ids.has(default_spawn):
		errors.append("room.default_spawn must reference an existing spawn")
	var assets: Dictionary = manifest.get("assets") if manifest.get("assets") is Dictionary else {}
	var shared_ids: Dictionary = {}
	RULES.validate_layers(room.get("layers"), assets, shared_ids, errors)
	RULES.validate_props(room.get("props"), assets, shared_ids, errors)
	RULES.validate_doors(room.get("doors"), shared_ids, errors)
	RULES.validate_interactions(room.get("interactions"), shared_ids, errors)
	RULES.validate_no_overlaps(room.get("doors"), room.get("interactions"), errors)
	RULES.validate_actors(room.get("actors"), errors)
	if not FIELDS.is_id(room.get("lighting_ref")):
		errors.append("room.lighting_ref is required")
	return FIELDS.result(errors)
