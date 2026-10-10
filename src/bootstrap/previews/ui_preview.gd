extends Node

signal back_requested

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const DIALOGUE = preload("res://src/presentation/coastal/dialogue_view.tscn")
const HUD = preload("res://src/presentation/coastal/hud_view.tscn")
const BACKDROP = preload("res://src/presentation/previews/preview_backdrop.gd")

var view: Control
var backdrop: Control
var toolbar: HBoxContainer
var _setup: Dictionary
var _resources: Dictionary
var _screen := "dialogue"
var _backdrops: Array = ["neutral", "ui-light", "ui-dark", "ui-detail"]
var _backdrop_index := 0


func _ready() -> void:
	_setup = STARTUP.prepare()
	if not _setup.ok:
		push_error(str(_setup.error))
		get_tree().quit(1)
		return
	_resources = STARTUP.ui_resources(_setup.data)
	backdrop = BACKDROP.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Interface.add_child(backdrop)
	show_case("dialogue", "neutral")
	_build_toolbar()


func show_case(screen: String, background: String, capture: bool = false) -> void:
	_screen = screen
	if view:
		$Interface.remove_child(view)
		view.queue_free()
	var profile: Dictionary = {"fill": "#62777b"} if background == "neutral" else _setup.data.dialogue_ui.backdrops[background]
	backdrop.configure(profile)
	view = DIALOGUE.instantiate() if screen == "dialogue" else HUD.instantiate()
	var model := STARTUP.fixture_model(_setup.data.preview[screen], _setup.text)
	model.focus = not capture
	view.configure(model, _setup.data["dialogue_ui" if screen == "dialogue" else "hud_ui"], _resources)
	if screen == "dialogue":
		view.choice_requested.connect(func(id: String) -> void: _choice(id))
		view.continue_requested.connect(func() -> void: show_case("hud", background))
	else:
		view.menu_requested.connect(func() -> void: back_requested.emit())
	$Interface.add_child(view)
	if toolbar:
		toolbar.visible = not capture
		$Interface.move_child(toolbar, -1)


func _build_toolbar() -> void:
	toolbar = HBoxContainer.new()
	toolbar.position = Vector2(365, 35)
	toolbar.add_theme_constant_override("separation", 12)
	for id: String in ["screen", "backdrop", "back"]:
		var button := Button.new()
		button.text = _setup.text.text("migration.preview." + id)
		if id == "back":
			button.icon = _resources["icon-back"]
		button.add_theme_font_override("font", _resources["Source Serif 4"])
		button.add_theme_font_size_override("font_size", 22)
		button.custom_minimum_size = Vector2(165, 46)
		button.pressed.connect(func() -> void: _toolbar_action(id))
		toolbar.add_child(button)
	$Interface.add_child(toolbar)


func _toolbar_action(id: String) -> void:
	if id == "back":
		back_requested.emit()
		return
	if id == "screen":
		_screen = "hud" if _screen == "dialogue" else "dialogue"
	else:
		_backdrop_index = (_backdrop_index + 1) % _backdrops.size()
	show_case(_screen, _backdrops[_backdrop_index])


func _choice(id: String) -> void:
	var model := STARTUP.fixture_model(_setup.data.preview.dialogue, _setup.text)
	model.selected_choice = id
	view.configure(model, _setup.data.dialogue_ui, _resources)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		back_requested.emit()
