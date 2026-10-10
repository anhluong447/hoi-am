extends Control
## Local view: receives resolved text and emits intent; owns no session or services.

signal quit_requested

var _model: Dictionary = {}


func configure(model: Dictionary) -> void:
	_model = model.duplicate(true)
	if is_node_ready():
		_render()


func _ready() -> void:
	%Quit.pressed.connect(func() -> void: quit_requested.emit())
	_render()
	%Quit.grab_focus()


func _render() -> void:
	%Title.text = _model.get("title", "")
	%Subtitle.text = _model.get("subtitle", "")
	%Quit.text = _model.get("quit", "")
