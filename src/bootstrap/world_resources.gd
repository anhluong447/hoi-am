extends RefCounted
## Composition loads world art once per mount and injects resources into the room.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const VALIDATION = preload("res://src/shared/world_art_validation.gd")


static func prepare(config: Dictionary, actor_textures: Dictionary, text_service: RefCounted = null) -> Dictionary:
	var result := {"ok": true, "config": config.duplicate(true), "textures": actor_textures.duplicate()}
	if not config.has("visuals_path"):
		return result
	if not config.get("world_art_path") is String:
		return {"ok": false, "error": {"code": "missing_world_art_path"}}
	var step: Variant = config.get("texel_step", 1.0)
	if not (step is int or step is float) or not is_finite(float(step)) or step <= 0 or not VALIDATION.motion(config.get("motion", {})):
		return {"ok": false, "error": {"code": "invalid_world_motion"}}
	var manifest := LOADER.read_dictionary(config.world_art_path)
	var visual := LOADER.read_dictionary(config.visuals_path)
	if not manifest.ok or not visual.ok or not VALIDATION.validate(manifest.data, visual.data):
		return {"ok": false, "error": {"code": "invalid_world_art"}}
	var resources := {"assets": {}, "textures": {}, "texel_step": config.get("texel_step", 1.0)}
	for asset: Dictionary in manifest.data.assets:
		resources.assets[asset.id] = asset
	var used: Dictionary = {}
	for prop: Dictionary in visual.data.get("props", []):
		for layer: Dictionary in prop.layers:
			used[layer.asset] = true
	for surface: Dictionary in visual.data.get("surfaces", []):
		used[surface.asset] = true
	var water: Dictionary = config.get("atmosphere", {}).get("water", {})
	if water.has("asset"):
		if not resources.assets.has(water.asset):
			return {"ok": false, "error": {"code": "missing_world_water"}}
		if water.get("visible", true):
			used[water.asset] = true
	var atlases: Dictionary = {}
	for id: String in used:
		atlases[resources.assets[id].atlas] = true
	for atlas: Dictionary in manifest.data.atlases:
		if not atlases.has(atlas.id):
			continue
		var texture := load(atlas.texture_path) as Texture2D
		if not texture:
			return {"ok": false, "error": {"code": "missing_world_texture"}}
		resources.textures[atlas.id] = texture
	result.config.visuals = visual.data.duplicate(true)
	if not visual.data.get("labels", []).is_empty():
		if not text_service:
			return {"ok": false, "error": {"code": "missing_world_text_service"}}
		if not config.get("world_font_path") is String or not ResourceLoader.exists(config.world_font_path):
			return {"ok": false, "error": {"code": "missing_world_font"}}
		resources.font = load(config.world_font_path) as Font
		if not resources.font:
			return {"ok": false, "error": {"code": "invalid_world_font"}}
		for label: Dictionary in result.config.visuals.labels:
			label.text = text_service.text(label.text_key)
	result.textures.world = resources
	return result
