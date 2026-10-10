extends Node
## Composition root and three concrete review entries.

const BOOTSTRAP_VIEW = preload("res://src/presentation/bootstrap/bootstrap_view.tscn")
const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const WORLD = preload("res://src/bootstrap/previews/world_preview.tscn")
const CALENDAR = preload("res://src/bootstrap/previews/calendar_preview.tscn")
const UI = preload("res://src/bootstrap/previews/ui_preview.tscn")

var session: RefCounted
var _boot_model: Dictionary
var _active: Node
var _dependencies: Dictionary


func _ready() -> void:
	var loaded := STARTUP.prepare()
	if not loaded["ok"]:
		push_error("Bootstrap content failed: %s" % loaded.get("error", {}))
		get_tree().quit(1)
		return
	session = loaded.session
	_dependencies = loaded
	_boot_model = STARTUP.fixture_model(loaded.data.bootstrap, loaded.text)
	get_window().title = _boot_model.title
	_show_boot()


func _show_boot() -> void:
	_clear_active()
	var view := BOOTSTRAP_VIEW.instantiate()
	view.configure(_boot_model)
	view.quit_requested.connect(_on_quit_requested)
	view.preview_requested.connect(_show_preview)
	$Interface.add_child(view)
	_active = view


func _show_preview(id: String) -> void:
	_clear_active()
	var scene: PackedScene = {"world": WORLD, "calendar": CALENDAR, "ui": UI}[id]
	_active = scene.instantiate()
	_active.back_requested.connect(func() -> void: _show_boot.call_deferred())
	add_child(_active)


func _clear_active() -> void:
	if is_instance_valid(_active):
		_active.get_parent().remove_child(_active)
		_active.queue_free()


func _on_quit_requested() -> void:
	get_tree().quit()
