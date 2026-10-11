extends RefCounted
## Composition loads world art once per mount and injects resources into the room.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const VALIDATION = preload("res://src/shared/world_art_validation.gd")


static func prepare(config: Dictionary, actor_textures: Dictionary) -> Dictionary:
	var result := {"ok": true, "config": config.duplicate(true), "textures": actor_textures.duplicate()}
	if not config.has("visuals_path"):
		return result
	var manifest := LOADER.read_dictionary(config.world_art_path)
	var visual := LOADER.read_dictionary(config.visuals_path)
	if not manifest.ok or not visual.ok or not VALIDATION.validate(manifest.data, visual.data):
		return {"ok": false, "error": {"code": "invalid_world_art"}}
	var resources := {"assets": {}, "textures": {}, "texel_step": config.get("texel_step", 1.0)}
	for atlas: Dictionary in manifest.data.atlases:
		var texture := load(atlas.texture_path) as Texture2D
		if not texture:
			return {"ok": false, "error": {"code": "missing_world_texture"}}
		resources.textures[atlas.id] = texture
	for asset: Dictionary in manifest.data.assets:
		resources.assets[asset.id] = asset
	result.config.visuals = visual.data
	result.textures.world = resources
	return result
