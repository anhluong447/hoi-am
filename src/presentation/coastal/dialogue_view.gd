extends Control

signal choice_requested(choice_id: String)
signal continue_requested
signal closed

const COMPONENTS = preload("res://src/presentation/coastal/dialogue_components.gd")
const MOTION = preload("res://src/presentation/coastal/dialogue_motion.gd")

var _model: Dictionary
var _layout: Dictionary
var _resources: Dictionary
var _labels: Dictionary
var _layers: Dictionary
var _buttons: Array[Button] = []
var _choice_art: Array[TextureRect] = []
var _choice_mark: Array[TextureRect] = []
var _choice_labels: Array[Label] = []
var _choices: Control
var _reading: Control
var _motion: Node
var _proceed: Button
var _line_tween: Tween
var _pending: Dictionary
var _state := "ready"
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
	if _line_tween:
		_line_tween.kill()
	if _motion:
		_motion.stop()
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_state = "ready"
	_pending.clear()
	var parts := COMPONENTS.build(self, _model, _layout, _resources)
	_labels = parts.labels
	_layers = parts.layers
	_reading = parts.reading
	_choices = parts.choices
	_proceed = parts.proceed
	_alias_choices()
	_choices.requested.connect(_request_choice)
	_choices.revealed.connect(_ready_to_advance)
	_reading.completed.connect(_text_finished)
	_proceed.pressed.connect(_request_continue)
	_motion = MOTION.new()
	add_child(_motion)
	_motion.configure(_layers, _layout.motion)
	if _choices.buttons.is_empty() and _model.get("focus", true):
		_proceed.grab_focus()


func _alias_choices() -> void:
	_buttons.assign(_choices.buttons)
	_buttons.append(_proceed)
	_choice_art = _choices.art
	_choice_mark = _choices.marks
	_choice_labels = _choices.labels


func present(reduced: bool) -> void:
	if _line_tween:
		_line_tween.kill()
	_pending.clear()
	_reading.stop()
	_reduced = reduced
	_state = "opening"
	_choices.configure(_model, _layout, _resources, true, reduced)
	_alias_choices()
	_choices.hide_rows()
	_layers.proceed.visible = false
	_proceed.disabled = true
	_proceed.focus_mode = Control.FOCUS_NONE
	_labels.line.visible = false
	_motion.open(reduced, _begin_text)


func _begin_text() -> void:
	_state = "revealing"
	_reading.start(_reduced)


func transition(model: Dictionary) -> void:
	if _state == "closing":
		return
	_pending = model.duplicate(true)
	_state = "changing"
	_choices.stop()
	_choices.hide_rows()
	_layers.proceed.visible = false
	_proceed.disabled = true
	_proceed.focus_mode = Control.FOCUS_NONE
	if _line_tween:
		_line_tween.kill()
	_line_tween = create_tween()
	_line_tween.tween_property(_layers.body, "modulate:a", 0.0, 0.0 if _reduced else _layout.motion.line_out_duration)
	if _pending.speaker != _model.speaker:
		_line_tween.parallel().tween_property(_layers.speaker, "modulate:a", 0.0, 0.0 if _reduced else _layout.motion.line_out_duration)
	_line_tween.tween_callback(_apply_line)
	_line_tween.tween_property(_layers.body, "modulate:a", 1.0, 0.0 if _reduced else _layout.motion.line_in_duration)
	_line_tween.parallel().tween_property(_layers.speaker, "modulate:a", 1.0, 0.0 if _reduced else _layout.motion.line_in_duration)


func _apply_line() -> void:
	_model = _pending.duplicate(true)
	_pending.clear()
	_reading.stop()
	for id: String in _labels:
		_labels[id].text = _model.get(id, "")
	_choices.configure(_model, _layout, _resources, true, _reduced)
	_choices.hide_rows()
	_alias_choices()
	_begin_text()


func finish_reveal() -> void:
	if _state == "opening":
		_motion.settle()
		_begin_text()
	elif _state == "changing":
		if _line_tween:
			_line_tween.kill()
		_apply_line()
		_layers.body.modulate.a = 1.0
		_layers.speaker.modulate.a = 1.0
	if _reading.revealing:
		if _line_tween:
			_line_tween.kill()
		_layers.body.modulate.a = 1.0
		_layers.speaker.modulate.a = 1.0
		_reading.finish()


func _text_finished() -> void:
	_state = "choices"
	_choices.reveal(_model.get("focus", true))


func _ready_to_advance() -> void:
	_state = "ready"
	_layers.proceed.visible = _model.choices.is_empty()
	_proceed.disabled = not _model.choices.is_empty()
	_proceed.focus_mode = Control.FOCUS_ALL if _model.choices.is_empty() else Control.FOCUS_NONE
	if _model.choices.is_empty() and _model.get("focus", true):
		_proceed.grab_focus()


func _request_choice(id: String) -> void:
	if _state != "ready":
		finish_reveal()
		return
	_state = "dispatched"
	_choices.set_enabled(false)
	choice_requested.emit(id)


func _request_continue() -> void:
	if _state != "ready":
		finish_reveal()
		return
	if not _model.choices.is_empty():
		return
	_state = "dispatched"
	_proceed.disabled = true
	continue_requested.emit()


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	var accept := event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")
	var click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if click:
		var region: Array = _layout.motion.advance_region
		click = Rect2(region[0], region[1], region[2], region[3]).has_point(get_global_transform_with_canvas().affine_inverse() * event.position)
	if (accept or click) and _state in ["opening", "changing", "revealing", "closing", "dispatched"]:
		finish_reveal()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo() or _state != "ready":
		return
	var accept := event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")
	var click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if click:
		var region: Array = _layout.motion.advance_region
		click = Rect2(region[0], region[1], region[2], region[3]).has_point(get_global_transform_with_canvas().affine_inverse() * event.position)
	if accept or click:
		if accept and not _model.choices.is_empty():
			_request_choice(_model.choices[maxi(_choices.selected, 0)].id)
		else:
			_request_continue()
		get_viewport().set_input_as_handled()


func dismiss() -> void:
	if is_closing():
		return
	_state = "closing"
	if _line_tween:
		_line_tween.kill()
	_reading.pause()
	_choices.stop()
	_choices.set_enabled(false)
	_proceed.disabled = true
	_proceed.focus_mode = Control.FOCUS_NONE
	_motion.close(func() -> void: closed.emit())


func is_closing() -> bool:
	return _state == "closing"


func body_text() -> String:
	return _labels.line.text if _labels.has("line") else ""
