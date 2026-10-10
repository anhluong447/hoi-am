extends RefCounted
## Shared concrete composition data. No global lifecycle or service lookup.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const CATALOG = preload("res://src/shared/text_catalog.gd")
const RULES = preload("res://src/domain/gameplay/gameplay_rules.gd")
const VALIDATOR = preload("res://src/domain/gameplay/state_validation.gd")
const CONTENT_VALIDATOR = preload("res://src/domain/gameplay/content_validation.gd")
const SESSION = preload("res://src/application/game_session.gd")
const TEXT = preload("res://src/presentation/controllers/gameplay_text.gd")


static func prepare() -> Dictionary:
	var manifest := LOADER.read_dictionary("res://content/manifest.json")
	if not manifest.ok:
		return manifest
	var data: Dictionary = {}
	for id: String in ["catalog", "bootstrap", "gameplay", "dialogue", "room", "actors", "dialogue_ui", "hud_ui", "ui_art", "preview"]:
		var path: Variant = manifest.data.get(id + "_path")
		if not path is String:
			return {"ok": false, "error": {"code": "missing_manifest_path", "field": id}}
		var loaded := LOADER.read_dictionary(path)
		if not loaded.ok:
			return loaded
		data[id] = loaded.data
	var catalog := CATALOG.new()
	var registered := catalog.set_catalog(data.catalog)
	if not registered.ok:
		return registered
	var validated := CONTENT_VALIDATOR.validate(data.gameplay, data.catalog)
	if not validated.ok:
		return validated
	var rules := RULES.new(data.gameplay)
	var validator := VALIDATOR.new(data.gameplay, data.catalog)
	var session := SESSION.new(rules.transition, validator.validate)
	var initial := rules.create_session()
	if not initial.ok:
		return initial
	var replaced := session.replace(initial.state)
	if not replaced.ok:
		return replaced
	return {"ok": true, "data": data, "catalog": catalog, "text": TEXT.new(catalog),
		"session": session, "rules": rules, "validator": validator}


static func ui_resources(data: Dictionary) -> Dictionary:
	var resources: Dictionary = {}
	for asset: Dictionary in data.ui_art.assets:
		resources[asset.id] = load(asset.texture_path)
	for family: String in data.preview.fonts:
		var font := FontVariation.new()
		font.base_font = load(data.preview.fonts[family])
		font.variation_opentype = {"wght": 500.0}
		resources[family] = font
	return resources


static func actor_textures(data: Dictionary) -> Dictionary:
	var textures: Dictionary = {}
	for id: String in data.actors.actors:
		textures[id] = load(data.actors.actors[id].texture_path)
	return textures


static func fixture_model(definition: Dictionary, text: RefCounted) -> Dictionary:
	var model: Dictionary = {}
	for field: String in definition:
		if field.ends_with("_key"):
			model[field.trim_suffix("_key")] = text.text(definition[field], definition.get(field.trim_suffix("_key") + "_parameters", {}))
		elif field == "choices":
			model.choices = []
			for choice: Dictionary in definition.choices:
				model.choices.append({"id": choice.id, "text": text.text(choice.text_key)})
		elif not field.ends_with("_parameters"):
			model[field] = definition[field]
	return model
