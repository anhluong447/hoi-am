extends Control

signal command_requested(command: Dictionary)

const WIDGETS = preload("res://src/presentation/coastal/coastal_widgets.gd")

var _model: Dictionary
var _definitions: Array
var _font: Font
var _message: Label


func configure(model: Dictionary, definitions: Array, font: Font) -> void:
	_model = model.duplicate(true)
	_definitions = definitions.duplicate(true)
	_font = font


func _ready() -> void:
	var box := VBoxContainer.new()
	box.position = Vector2(600, 210)
	box.size = Vector2(460, 430)
	box.add_theme_constant_override("separation", 12)
	add_child(box)
	for definition: Dictionary in _definitions:
		var button := Button.new()
		button.text = _model[definition.id]
		button.custom_minimum_size.y = 54
		button.add_theme_font_override("font", _font)
		button.add_theme_font_size_override("font_size", 25)
		button.pressed.connect(func() -> void: command_requested.emit(definition.command.duplicate(true)))
		box.add_child(button)
	_message = WIDGETS.copy(self, "", {"x": 390, "y": 715, "size": 24, "width": 880, "height": 90, "fill": "#f6eed9"}, _font)
	box.get_child(0).grab_focus()


func show_message(value: String) -> void:
	_message.text = value
