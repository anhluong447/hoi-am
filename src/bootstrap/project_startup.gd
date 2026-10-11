extends RefCounted
## Shared concrete composition data. No global lifecycle or service lookup.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const CATALOG = preload("res://src/shared/text_catalog.gd")
const RULES = preload("res://src/domain/gameplay/gameplay_rules.gd")
const VALIDATOR = preload("res://src/domain/gameplay/state_validation.gd")
const CONTENT_VALIDATOR = preload("res://src/domain/gameplay/content_validation.gd")
const SESSION = preload("res://src/application/game_session.gd")
const TEXT = preload("res://src/presentation/controllers/gameplay_text.gd")
const GRAPH = preload("res://src/domain/dialogue/dialogue_graph.gd")


static func prepare(reading_room_extension: bool = false) -> Dictionary:
	var manifest := LOADER.read_dictionary("res://content/manifest.json")
	if not manifest.ok:
		return manifest
	var data: Dictionary = {}
	for id: String in ["catalog", "bootstrap", "gameplay", "dialogue", "room", "actors", "dialogue_ui", "hud_ui", "ui_art", "preview", "workspace", "playable_dialogue", "locations"]:
		var path: Variant = manifest.data.get(id + "_path")
		if not path is String:
			return {"ok": false, "error": {"code": "missing_manifest_path", "field": id}}
		var loaded := LOADER.read_dictionary(path)
		if not loaded.ok:
			return loaded
		data[id] = loaded.data
	if reading_room_extension:
		var example := LOADER.read_dictionary("res://content/extensions/reading_room/case.json")
		var graph := LOADER.read_dictionary("res://content/extensions/reading_room/dialogue.json")
		if not example.ok or not graph.ok:
			return {"ok": false, "error": {"code": "extension_content_failed"}}
		data.gameplay.cases.append(example.data)
		data.playable_dialogue.scenes["library-visitor"] = graph.data
	var catalog := CATALOG.new()
	var registered := catalog.set_catalog(data.catalog)
	if not registered.ok:
		return registered
	var validated := CONTENT_VALIDATOR.validate(data.gameplay, data.catalog)
	if not validated.ok:
		return validated
	for graph: Dictionary in data.dialogue.scenes.values() + data.playable_dialogue.scenes.values():
		if not GRAPH.validate(graph, data.catalog):
			return {"ok": false, "error": {"code": "invalid_dialogue_graph", "text_key": "save.invalid"}}
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
	var resources: Dictionary = {"coastal_weights": {}}
	var specs: Array = data.dialogue_ui.text + data.dialogue_ui.environmentText + data.hud_ui.text
	specs.append(data.hud_ui.prompt)
	specs.append(data.dialogue_ui.choice_copy.selected)
	for choice: Dictionary in data.dialogue_ui.choices:
		specs.append(choice.font)
	for asset: Dictionary in data.ui_art.assets:
		resources[asset.id] = load(asset.texture_path)
	for family: String in data.preview.fonts:
		var font := FontVariation.new()
		font.base_font = load(data.preview.fonts[family])
		font.variation_opentype = {"wght": 500.0}
		# Composition retains immutable weights across view rebuilds and focus changes.
		var weights: Dictionary = {500.0: font}
		for spec: Dictionary in specs:
			if spec.get("family", "Source Serif 4") != family or not spec.has("weight"):
				continue
			var weight := float(spec.weight)
			if not weights.has(weight):
				var variation := FontVariation.new()
				variation.base_font = font.base_font
				variation.variation_opentype = {"wght": weight}
				weights[weight] = variation
		resources.coastal_weights[family] = weights
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
