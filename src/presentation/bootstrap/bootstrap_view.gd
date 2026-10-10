extends Control
## Local view: receives resolved text and emits intent; owns no session or services.

signal quit_requested
signal preview_requested(preview_id: String)

var _model: Dictionary = {}


func configure(model: Dictionary) -> void:
	_model = model.duplicate(true)
	if is_node_ready():
		_render()


func _ready() -> void:
	%Quit.pressed.connect(func() -> void: quit_requested.emit())
	for id: String in ["play", "sandbox", "world", "calendar", "ui"]:
		get_node("Center/Content/" + id).pressed.connect(func() -> void: preview_requested.emit(id))
	_render()
	get_node("Center/Content/play").grab_focus()


func _render() -> void:
	%Title.text = _model.get("title", "")
	%Subtitle.text = _model.get("subtitle", "")
	%Quit.text = _model.get("quit", "")
	for id: String in ["play", "sandbox", "world", "calendar", "ui"]:
		get_node("Center/Content/" + id).text = _model.get(id, "")
