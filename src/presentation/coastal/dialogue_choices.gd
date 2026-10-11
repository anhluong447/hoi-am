extends Control
## Animated visuals share fixed, unscaled hit targets and stable choice IDs.

signal requested(choice_id: String)
signal revealed

const WIDGETS = preload("res://src/presentation/coastal/coastal_widgets.gd")

var buttons: Array[Button] = []
var art: Array[TextureRect] = []
var marks: Array[TextureRect] = []
var labels: Array[Label] = []
var _rows: Array[Control] = []
var _gold: Array[TextureRect] = []
var _specs: Array[Dictionary] = []
var _targets: Array[Vector2] = []
var _focus_tweens: Array[Tween] = []
var _entrance: Tween
var _layout: Dictionary
var _resources: Dictionary
var _animated := false
var _reduced := false
var selected := -1
var _resting := 0


func configure(model: Dictionary, layout: Dictionary, resources: Dictionary, animated: bool, reduced: bool) -> void:
	stop()
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	buttons.clear()
	art.clear()
	marks.clear()
	labels.clear()
	_rows.clear()
	_gold.clear()
	_specs.clear()
	_targets.clear()
	_focus_tweens.clear()
	_layout = layout
	_resources = resources
	_animated = animated
	_reduced = reduced
	selected = -1
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 1.0
	for index: int in mini(model.choices.size(), layout.choices.size()):
		var choice: Dictionary = model.choices[index]
		var spec: Dictionary = layout.choices[index]
		var row := Control.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.pivot_offset = WIDGETS.rectangle(spec.bounds).get_center()
		add_child(row)
		_rows.append(row)
		_focus_tweens.append(null)
		art.append(WIDGETS.art(row, resources["choice-plain"], spec.bounds))
		_gold.append(WIDGETS.art(row, resources["choice-gold"], spec.bounds))
		WIDGETS.art(row, resources["icon-" + spec.icon], [spec.bounds[0] + 29, spec.bounds[1] + 16, 28, 28])
		var mark := WIDGETS.art(row, resources["icon-chevron"], [spec.bounds[0] + spec.bounds[2] - 40, spec.bounds[1] + 15, 25, 29])
		marks.append(mark)
		_targets.append(mark.position)
		var copy_spec: Dictionary = spec.font.duplicate(true)
		copy_spec.merge({"x": spec.baseline[0], "y": spec.baseline[1]})
		copy_spec.width = spec.bounds[2] - (spec.baseline[0] - spec.bounds[0]) - layout.choice_copy.right_margin
		copy_spec.height = spec.bounds[3] - 2 * layout.choice_copy.padding
		var copy := WIDGETS.copy(row, choice.text, copy_spec, resources["Source Serif 4"], resources.coastal_weights["Source Serif 4"])
		copy.max_lines_visible = layout.choice_copy.max_lines
		copy.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		labels.append(copy)
		_specs.append(copy_spec)
		var button := WIDGETS.target(self, spec.bounds, choice.text)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.tooltip_text = choice.text
		button.pressed.connect(func() -> void: requested.emit(choice.id))
		button.focus_entered.connect(func() -> void: select(index))
		button.mouse_entered.connect(func() -> void: select(index))
		button.mouse_exited.connect(_restore_focus)
		buttons.append(button)
	var initial := 0
	for index: int in buttons.size():
		if model.choices[index].id == model.get("selected_choice", ""):
			initial = index
	if not buttons.is_empty():
		_resting = initial
		select(initial, true)
		if model.get("focus", true) and not animated:
			buttons[initial].grab_focus()


func _restore_focus() -> void:
	var focused := buttons.find(get_viewport().gui_get_focus_owner())
	select(focused if focused >= 0 else _resting)


func select(index: int, instant: bool = false) -> void:
	if selected == index and not instant:
		return
	selected = index
	for candidate: int in _rows.size():
		if _focus_tweens[candidate]:
			_focus_tweens[candidate].kill()
		var active := candidate == index
		var style: Dictionary = _layout.choice_copy.selected if active else _layout.choices[candidate].font
		var copy := labels[candidate]
		copy.add_theme_font_override("font", WIDGETS.styled_font(_resources["Source Serif 4"], style, _resources.coastal_weights["Source Serif 4"]))
		_fit(candidate)
		marks[candidate].visible = active
		var target_scale: Vector2 = Vector2.ONE * (_layout.motion.choices.focus_scale if active and _animated and not _reduced else 1.0)
		var mark_position := _targets[candidate] - Vector2(_layout.motion.choices.chevron_offset if active and _animated and not _reduced else 0, 0)
		if instant or not _animated or _reduced:
			_rows[candidate].scale = target_scale
			_gold[candidate].modulate.a = 1.0 if active else 0.0
			art[candidate].modulate.a = 0.0 if active else 1.0
			copy.add_theme_color_override("font_color", Color(style.fill))
			marks[candidate].position = mark_position
			continue
		var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_focus_tweens[candidate] = tween
		var duration: float = _layout.motion.choices.focus_duration
		tween.tween_property(_rows[candidate], "scale", target_scale, duration)
		tween.tween_property(_gold[candidate], "modulate:a", 1.0 if active else 0.0, duration)
		tween.tween_property(art[candidate], "modulate:a", 0.0 if active else 1.0, duration)
		tween.tween_property(marks[candidate], "position", mark_position, duration)
		tween.tween_method(func(color: Color) -> void: copy.add_theme_color_override("font_color", color), copy.get_theme_color("font_color"), Color(style.fill), duration)


func _fit(index: int) -> void:
	var copy := labels[index]
	var spec: Dictionary = _specs[index]
	WIDGETS.refresh_copy(copy, copy.text, spec)
	var font_size := roundi(spec.size)
	while copy.get_minimum_size().y > spec.height and font_size > _layout.choice_copy.min_size:
		font_size -= 1
		copy.add_theme_font_size_override("font_size", font_size)
	if copy.get_line_count() > 1:
		var bounds: Array = _layout.choices[index].bounds
		copy.position.y = bounds[1] + (bounds[3] - copy.get_minimum_size().y) / 2.0
		copy.size.y = copy.get_minimum_size().y


func hide_rows() -> void:
	for row: Control in _rows:
		row.modulate.a = 0.0
	set_enabled(false)


func reveal(focus: bool) -> void:
	if _entrance:
		_entrance.kill()
	if _reduced or _rows.is_empty():
		_complete(focus)
		return
	_entrance = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for index: int in _rows.size():
		var spec: Dictionary = _layout.motion.choices
		_rows[index].position = Vector2(spec.offset[0], spec.offset[1])
		_rows[index].modulate.a = 0.0
		_entrance.tween_property(_rows[index], "position", Vector2.ZERO, spec.duration).set_delay(index * spec.stagger)
		_entrance.tween_property(_rows[index], "modulate:a", 1.0, spec.duration).set_delay(index * spec.stagger)
	_entrance.chain().tween_callback(func() -> void: _complete(focus))


func _complete(focus: bool) -> void:
	for row: Control in _rows:
		row.position = Vector2.ZERO
		row.modulate.a = 1.0
	set_enabled(true)
	if focus and selected >= 0:
		buttons[selected].grab_focus()
	revealed.emit()


func set_enabled(enabled: bool) -> void:
	for button: Button in buttons:
		button.disabled = not enabled
		button.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE


func stop() -> void:
	# Each tween belongs to one visual property family and is cancelled on disposal.
	if _entrance:
		_entrance.kill()
	for tween: Tween in _focus_tweens:
		if tween:
			tween.kill()


func close_rows() -> void:
	stop()
	set_enabled(false)
	if _rows.is_empty():
		return
	_entrance = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var settings: Dictionary = _layout.motion.choices
	var duration: float = _layout.motion.closing.choices.duration
	for index: int in _rows.size():
		var delay: float = _layout.motion.closing.choices.delay + (_rows.size() - 1 - index) * settings.stagger
		_entrance.tween_property(_rows[index], "modulate:a", 0.0, duration).set_delay(delay)
		_entrance.tween_property(_rows[index], "position", Vector2(settings.offset[0], settings.offset[1]), duration).set_delay(delay)
		_entrance.tween_property(_rows[index], "scale", Vector2.ONE, duration).set_delay(delay)
