extends Control

signal menu_requested

const WIDGETS = preload("res://src/presentation/coastal/coastal_widgets.gd")

var _model: Dictionary
var _layout: Dictionary
var _resources: Dictionary
var _labels: Dictionary = {}
var _prompt: Label


func configure(model: Dictionary, layout: Dictionary, resources: Dictionary) -> void:
	_model = model.duplicate(true)
	_layout = layout.duplicate(true)
	_resources = resources
	if is_node_ready():
		_build()


func _ready() -> void:
	_build()


func render(model: Dictionary) -> void:
	_model = model.duplicate(true)
	for id: String in _labels:
		_labels[id].text = _model.get(id, "")


func show_prompt(value: String, anchor: Dictionary) -> void:
	if _prompt:
		_prompt.text = value
		_prompt.visible = anchor.get("visible", false) and not value.is_empty()
		if _prompt.visible:
			_prompt.position = anchor.position - Vector2(_prompt.size.x / 2.0, _prompt.size.y)


func _build() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_labels.clear()
	if _layout.is_empty():
		return
	for panel: Dictionary in _layout.panels:
		var background := Panel.new()
		background.position = WIDGETS.rectangle(panel.bounds).position
		background.size = WIDGETS.rectangle(panel.bounds).size
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(panel.color)
		style.border_color = Color(panel.border)
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		background.add_theme_stylebox_override("panel", style)
		add_child(background)
	WIDGETS.art(self, _resources["date-paper"], _layout.date_paper)
	WIDGETS.art(self, _resources["sun-seal"], _layout.sun_seal)
	for spec: Dictionary in _layout.text:
		_labels[spec.id] = WIDGETS.copy(self, _model.get(spec.id, ""), spec, _resources[spec.get("family", "Source Serif 4")])
	var menu := WIDGETS.target(self, _layout.menu_bounds, _model.get("menu", ""))
	menu.pressed.connect(func() -> void: menu_requested.emit())
	_prompt = WIDGETS.copy(self, "", _layout.prompt, _resources["Source Serif 4"])
	_prompt.add_theme_color_override("font_shadow_color", Color("#172535"))
	_prompt.add_theme_constant_override("shadow_offset_x", 1)
	_prompt.add_theme_constant_override("shadow_offset_y", 1)
	_prompt.visible = false
