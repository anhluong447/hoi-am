extends RefCounted
## Section-level rules for side-room and art-manifest validation; pure, no I/O.

const PLANES := ["sky", "far", "back", "mid", "foreground"]
const FIELDS = preload("res://src/shared/side_room_fields.gd")


static func validate_image_asset(ref: String, asset: Dictionary, errors: Array[String]) -> void:
	if not FIELDS.is_path(asset.get("path")):
		errors.append("Asset %s path must start with res://" % ref)
	if not FIELDS.is_size(asset.get("size")):
		errors.append("Asset %s size must be two positive numbers" % ref)
	if not FIELDS.is_positive_number(asset.get("px_per_unit")):
		errors.append("Asset %s px_per_unit must be positive" % ref)
	if not FIELDS.is_position(asset.get("pivot")):
		errors.append("Asset %s pivot must be two finite numbers" % ref)
	if asset.get("status") != "placeholder_ai" and asset.get("status") != "final":
		errors.append("Asset %s status must be placeholder_ai or final" % ref)
	if not FIELDS.is_sha256(asset.get("sha256")):
		errors.append("Asset %s sha256 must be a 64 character hex digest" % ref)
	var provenance: Variant = asset.get("provenance")
	if not provenance is Dictionary or not FIELDS.is_id(provenance.get("tool")) or not FIELDS.is_id(provenance.get("prompt_id")) or not FIELDS.is_id(provenance.get("date")):
		errors.append("Asset %s provenance must name tool, prompt_id and date" % ref)


static func validate_phase(phase_id: String, phase: Variant, errors: Array[String]) -> void:
	if not phase is Dictionary:
		errors.append("Phase %s must be a dictionary" % phase_id)
		return
	if not FIELDS.is_color(phase.get("modulate")):
		errors.append("Phase %s modulate must be #rrggbb" % phase_id)
	var sun: Variant = phase.get("sun")
	if not sun is Dictionary or not FIELDS.is_color(sun.get("color")) or not FIELDS.is_finite_number(sun.get("energy")) or not FIELDS.is_finite_number(sun.get("angle")):
		errors.append("Phase %s sun must have color, energy and angle" % phase_id)
	var lights: Variant = phase.get("lights")
	if not lights is Array:
		errors.append("Phase %s lights must be an array" % phase_id)
	else:
		for light: Variant in lights:
			if not light is Dictionary or not FIELDS.is_id(light.get("id")) or not FIELDS.is_position(light.get("position")) or not FIELDS.is_color(light.get("color")) or not FIELDS.is_finite_number(light.get("energy")) or not FIELDS.is_finite_number(light.get("radius")):
				errors.append("Phase %s has an invalid light" % phase_id)
	var dust: Variant = phase.get("dust")
	if not FIELDS.is_finite_number(dust) or float(dust) < 0.0 or float(dust) > 1.0:
		errors.append("Phase %s dust must be within 0..1" % phase_id)
	if not FIELDS.is_color(phase.get("water_tint")):
		errors.append("Phase %s water_tint must be #rrggbb" % phase_id)


static func validate_spawns(value: Variant, bounds_valid: bool, min_x: float, max_x: float, errors: Array[String]) -> Dictionary:
	var spawn_ids: Dictionary = {}
	if not value is Dictionary or value.is_empty():
		errors.append("room.spawns requires at least one entry")
		return spawn_ids
	for spawn_id: Variant in value.keys():
		var spawn: Variant = value[spawn_id]
		var facing: Variant = spawn.get("facing") if spawn is Dictionary else null
		if not FIELDS.is_id(spawn_id) or not spawn is Dictionary or not FIELDS.is_finite_number(spawn.get("x")) or (facing != -1 and facing != 1):
			errors.append("Spawn %s is invalid" % str(spawn_id))
			continue
		if bounds_valid and not (float(spawn.x) >= min_x and float(spawn.x) <= max_x):
			errors.append("Spawn %s x is outside room bounds" % str(spawn_id))
		spawn_ids[spawn_id] = true
	return spawn_ids


static func validate_layers(value: Variant, assets: Dictionary, shared_ids: Dictionary, errors: Array[String]) -> void:
	if not value is Array:
		errors.append("room.layers must be an array")
		return
	for layer: Variant in value:
		if not layer is Dictionary or not FIELDS.claim_id(layer.get("id"), shared_ids, errors):
			continue
		var id: String = layer.id
		if not PLANES.has(layer.get("plane")):
			errors.append("Layer %s has an unknown plane" % id)
		if not FIELDS.is_finite_number(layer.get("scroll_scale")):
			errors.append("Layer %s scroll_scale must be finite" % id)
		if not assets.has(layer.get("art_ref")):
			errors.append("Layer %s art_ref is not in the manifest" % id)
		if not FIELDS.is_position(layer.get("position")):
			errors.append("Layer %s position must be two finite numbers" % id)
		if not layer.get("z") is int:
			errors.append("Layer %s z must be an int" % id)


static func validate_props(value: Variant, assets: Dictionary, shared_ids: Dictionary, errors: Array[String]) -> void:
	if not value is Array:
		errors.append("room.props must be an array")
		return
	for prop: Variant in value:
		if not prop is Dictionary or not FIELDS.claim_id(prop.get("id"), shared_ids, errors):
			continue
		var id: String = prop.id
		if not assets.has(prop.get("art_ref")):
			errors.append("Prop %s art_ref is not in the manifest" % id)
		if not FIELDS.is_position(prop.get("position")):
			errors.append("Prop %s position must be two finite numbers" % id)
		if not FIELDS.is_finite_number(prop.get("sort_y")):
			errors.append("Prop %s sort_y must be finite" % id)
		if not prop.get("occludes_actor") is bool:
			errors.append("Prop %s occludes_actor must be a bool" % id)


static func validate_doors(value: Variant, shared_ids: Dictionary, errors: Array[String]) -> void:
	if not value is Array:
		errors.append("room.doors must be an array")
		return
	for door: Variant in value:
		if not door is Dictionary or not FIELDS.claim_id(door.get("id"), shared_ids, errors):
			continue
		var id: String = door.id
		if not FIELDS.is_finite_number(door.get("x")):
			errors.append("Door %s x must be finite" % id)
		if not FIELDS.is_positive_number(door.get("width")):
			errors.append("Door %s width must be positive" % id)
		if not FIELDS.is_id(door.get("target_room")):
			errors.append("Door %s target_room is required" % id)
		if not FIELDS.is_id(door.get("target_spawn")):
			errors.append("Door %s target_spawn is required" % id)
		if door.has("target_location") and not FIELDS.is_id(door.get("target_location")):
			errors.append("Door %s target_location must be a non-empty string" % id)


static func validate_interactions(value: Variant, shared_ids: Dictionary, errors: Array[String]) -> void:
	if not value is Array:
		errors.append("room.interactions must be an array")
		return
	for interaction: Variant in value:
		if not interaction is Dictionary or not FIELDS.claim_id(interaction.get("id"), shared_ids, errors):
			continue
		var id: String = interaction.id
		if not FIELDS.is_finite_number(interaction.get("x")):
			errors.append("Interaction %s x must be finite" % id)
		if not FIELDS.is_positive_number(interaction.get("width")):
			errors.append("Interaction %s width must be positive" % id)
		if not FIELDS.is_id(interaction.get("label_key")):
			errors.append("Interaction %s label_key is required" % id)
		if not FIELDS.is_finite_number(interaction.get("anchor_y")):
			errors.append("Interaction %s anchor_y must be finite" % id)


static func validate_actors(value: Variant, errors: Array[String]) -> void:
	if not value is Array:
		errors.append("room.actors must be an array")
		return
	var actor_ids: Dictionary = {}
	for actor: Variant in value:
		var facing: Variant = actor.get("facing") if actor is Dictionary else null
		if not actor is Dictionary or not FIELDS.is_id(actor.get("id")) or not FIELDS.is_id(actor.get("actor_ref")) or not FIELDS.is_finite_number(actor.get("x")) or (facing != -1 and facing != 1):
			errors.append("Actor entry is invalid")
			continue
		if actor_ids.has(actor.id):
			errors.append("Duplicate actor id: %s" % actor.id)
		actor_ids[actor.id] = true
