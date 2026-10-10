extends Control

signal menu_requested
signal map_requested

const WIDGETS = preload("res://src/presentation/coastal/coastal_widgets.gd")
const GAUGE = preload("res://src/presentation/coastal/energy_gauge.gd")

var _model: Dictionary
var _layout: Dictionary
var _resources: Dictionary
var _labels: Dictionary = {}
var _prompt: Label
var _prompt_box: PanelContainer
var _gauge: Control
var _map: Button
var _menu: Button


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
	for spec: Dictionary in _layout.text:
		WIDGETS.refresh_copy(_labels[spec.id], _model.get(spec.id, ""), spec)
	_gauge.update_value(_model.energy_value, _model.energy_capacity)
	_map.accessibility_name = _model.map
	_menu.accessibility_name = _model.menu


func show_prompt(value: String, anchor: Dictionary) -> void:
	if not _prompt:
		return
	_prompt.text = value
	_prompt.visible = anchor.get("visible", false) and not value.is_empty()
	_prompt_box.visible = _prompt.visible
	if _prompt.visible:
		_prompt_box.size = _prompt.get_minimum_size() + Vector2(_layout.prompt.padding[0], _layout.prompt.padding[1]) * 2
		var extent := get_viewport().get_visible_rect().size
		var point: Vector2 = anchor.position - Vector2(_prompt_box.size.x / 2.0, _prompt_box.size.y + _layout.prompt.offset)
		_prompt_box.position = point.clamp(Vector2.ONE * _layout.prompt.margin, extent - _prompt_box.size - Vector2.ONE * _layout.prompt.margin)


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed("map") and not event.is_echo():
		map_requested.emit()
		get_viewport().set_input_as_handled()


func _build() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_labels.clear()
	if _layout.is_empty():
		return
	WIDGETS.art(self, _resources["hud-frame"], [0, 0, _layout.stage[0], _layout.stage[1]])
	_gauge = GAUGE.new()
	_gauge.configure(_layout.pips, _model.energy_value, _model.energy_capacity)
	add_child(_gauge)
	for spec: Dictionary in _layout.text:
		_labels[spec.id] = WIDGETS.copy(self, _model.get(spec.id, ""), spec, _resources[spec.get("family", "Source Serif 4")])
	_map = WIDGETS.target(self, _layout.map_bounds, _model.map)
	_map.pressed.connect(func() -> void: map_requested.emit())
	_menu = WIDGETS.target(self, _layout.menu_bounds, _model.menu)
	_menu.pressed.connect(func() -> void: menu_requested.emit())
	_prompt_box = PanelContainer.new()
	_prompt_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxTexture.new()
	style.texture = _resources["hud-prompt"]
	style.set_texture_margin_all(_layout.prompt.texture_margin)
	style.content_margin_left = _layout.prompt.padding[0]
	style.content_margin_right = _layout.prompt.padding[0]
	style.content_margin_top = _layout.prompt.padding[1]
	style.content_margin_bottom = _layout.prompt.padding[1]
	_prompt_box.add_theme_stylebox_override("panel", style)
	add_child(_prompt_box)
	_prompt = WIDGETS.copy(_prompt_box, "", _layout.prompt, _resources["Source Serif 4"])
	_prompt_box.visible = false
	_prompt.visible = false
