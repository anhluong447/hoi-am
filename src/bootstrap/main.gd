extends Node
## Composition root. A real gameplay session is wired here after its ruleset port.

const CONTENT_LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const TEXT_CATALOG = preload("res://src/shared/text_catalog.gd")
const BOOTSTRAP_VIEW = preload("res://src/presentation/bootstrap/bootstrap_view.tscn")


func _ready() -> void:
	var loaded := _load_view_model()
	if not loaded["ok"]:
		push_error("Bootstrap content failed: %s" % loaded.get("error", {}))
		get_tree().quit(1)
		return
	var model: Dictionary = loaded["model"]
	get_window().title = model["title"]
	var view := BOOTSTRAP_VIEW.instantiate()
	view.configure(model)
	view.quit_requested.connect(_on_quit_requested)
	$Interface.add_child(view)


func _load_view_model() -> Dictionary:
	var manifest := CONTENT_LOADER.read_dictionary("res://content/manifest.json")
	if not manifest["ok"]:
		return manifest
	var paths: Dictionary = manifest["data"]
	for field: String in ["catalog_path", "bootstrap_path"]:
		if not paths.get(field) is String:
			return {"ok": false, "error": {"code": "invalid_manifest_path", "field": field}}
	var catalog_data := CONTENT_LOADER.read_dictionary(paths["catalog_path"])
	if not catalog_data["ok"]:
		return catalog_data
	var catalog := TEXT_CATALOG.new()
	var registered := catalog.set_catalog(catalog_data["data"])
	if not registered["ok"]:
		return registered
	var layout := CONTENT_LOADER.read_dictionary(paths["bootstrap_path"])
	if not layout["ok"]:
		return layout
	var model: Dictionary = {}
	for field: String in ["title", "subtitle", "quit"]:
		var key: Variant = layout["data"].get(field + "_key")
		if not key is String:
			return {"ok": false, "error": {"code": "invalid_view_text_key", "field": field}}
		var resolved := catalog.format_text(key)
		if not resolved["ok"]:
			return resolved
		model[field] = resolved["text"]
	return {"ok": true, "model": model}


func _on_quit_requested() -> void:
	get_tree().quit()
