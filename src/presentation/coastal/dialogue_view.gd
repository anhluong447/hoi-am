extends Control

signal choice_requested(choice_id: String)
signal continue_requested

const WIDGETS = preload("res://src/presentation/coastal/coastal_widgets.gd")

var _model: Dictionary
var _layout: Dictionary
var _resources: Dictionary
var _buttons: Array[Button] = []
var _choice_art: Array[TextureRect] = []
var _choice_mark: Array[TextureRect] = []
var _labels: Dictionary = {}
var _choice_labels: Array[Label] = []
var _motion: Tween
var _reduced := false


func configure(model: Dictionary, layout: Dictionary, resources: Dictionary) -> void:
	_model = model.duplicate(true)
	_layout = layout.duplicate(true)
	_resources = resources
	if is_node_ready():
		_build()


func _ready() -> void:
	_build()


func _build() -> void:
	if _motion:
		_motion.kill()
	modulate.a = 1.0
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_buttons.clear()
	_choice_art.clear()
	_choice_mark.clear()
	_labels.clear()
	_choice_labels.clear()
	if _model.is_empty():
		return
	for layer: String in ["wave", "paper", "dialogue-wash", "print", "date"]:
		WIDGETS.art(self, _resources[layer], [0, 0, _layout.stage[0], _layout.stage[1]])
	for spec: Dictionary in _layout.text:
		if spec.get("optionalLogo", false):
			continue
		_labels[spec.id] = WIDGETS.copy(self, _model.get(spec.id, ""), spec, _resources[spec.get("family", "Source Serif 4")])
	for index: int in _model.choices.size():
		if index >= _layout.choices.size():
			break
		var choice: Dictionary = _model.choices[index]
		var spec: Dictionary = _layout.choices[index]
		var selected: bool = choice.id == _model.get("selected_choice", "")
		var texture: Texture2D = _resources["choice-gold" if selected else "choice-plain"]
		_choice_art.append(WIDGETS.art(self, texture, spec.bounds))
		WIDGETS.art(self, _resources["icon-" + spec.icon], [spec.bounds[0] + 29, spec.bounds[1] + 16, 28, 28])
		var mark := WIDGETS.art(self, _resources["icon-chevron"], [spec.bounds[0] + spec.bounds[2] - 40, spec.bounds[1] + 15, 25, 29])
		mark.visible = selected
		_choice_mark.append(mark)
		var copy_spec: Dictionary = spec.font.duplicate(true)
		copy_spec.merge({"x": spec.baseline[0], "y": spec.baseline[1]})
		copy_spec.width = spec.bounds[2] - (spec.baseline[0] - spec.bounds[0]) - _layout.choice_copy.right_margin
		copy_spec.height = spec.bounds[3] - 2 * _layout.choice_copy.padding
		var copy := WIDGETS.copy(self, choice.text, copy_spec, _resources["Source Serif 4"])
		copy.max_lines_visible = _layout.choice_copy.max_lines
		copy.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var font_size := roundi(copy_spec.size)
		while copy.get_minimum_size().y > copy_spec.height and font_size > _layout.choice_copy.min_size:
			font_size -= 1
			copy.add_theme_font_size_override("font_size", font_size)
		if copy.get_line_count() > 1:
			copy.position.y = spec.bounds[1] + (spec.bounds[3] - copy.get_minimum_size().y) / 2.0
			copy.size.y = copy.get_minimum_size().y
		_choice_labels.append(copy)
		var button := WIDGETS.target(self, spec.bounds, choice.text)
		button.tooltip_text = choice.text
		button.pressed.connect(func() -> void: choice_requested.emit(choice.id))
		button.focus_entered.connect(func() -> void: _select(index))
		button.mouse_entered.connect(func() -> void: _select(index))
		_buttons.append(button)
	WIDGETS.art(self, _resources["icon-return"], _layout.returnIcon)
	var proceed := WIDGETS.target(self, _layout.continueBounds, _model.get("continue", ""))
	proceed.pressed.connect(func() -> void: continue_requested.emit())
	_buttons.append(proceed)
	# Decoration art ignores pointer input; hit targets stay available through alpha.
	for layer: String in ["flowers", "notebook", "note-wash"]:
		WIDGETS.art(self, _resources[layer], [0, 0, _layout.stage[0], _layout.stage[1]])
	for spec: Dictionary in _layout.environmentText:
		var adjusted := spec.duplicate(true)
		adjusted.x = 0
		adjusted.y = 0
		var pose: Dictionary = _layout.note_copy
		var rig := Node2D.new()
		rig.transform = Transform2D(Vector2(pose.basis[0], pose.basis[1]), Vector2(pose.basis[2], pose.basis[3]), Vector2(pose.origin[0], pose.origin[1])) * Transform2D(deg_to_rad(pose.rotation), Vector2(pose.anchor[0], pose.anchor[1]))
		add_child(rig)
		var surface := Control.new()
		surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rig.add_child(surface)
		WIDGETS.copy(surface, _model.get(spec.id, ""), adjusted, _resources[spec.family])
	if _model.get("focus", true):
		_buttons[0].grab_focus()


func _select(index: int) -> void:
	for candidate: int in _choice_art.size():
		_choice_art[candidate].texture = _resources["choice-gold" if candidate == index else "choice-plain"]
		_choice_mark[candidate].visible = candidate == index


func body_text() -> String:
	return _labels.line.text if _labels.has("line") else ""


func present(reduced: bool) -> void:
	_reduced = reduced
	if _motion:
		_motion.kill()
	modulate.a = 1.0 if reduced else 0.0
	if not reduced:
		_motion = create_tween()
		_motion.tween_property(self, "modulate:a", 1.0, _layout.motion.enter_duration)
