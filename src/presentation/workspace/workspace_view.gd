extends Control

signal command_requested(command: Dictionary)
signal section_requested(section: String)
signal close_requested

var _layout: Dictionary
var _model: Dictionary
var _font: Font
var _content: VBoxContainer
var _scroll: ScrollContainer
var _motion: Tween
var _reduced := false


func configure(model: Dictionary, layout: Dictionary, font: Font) -> void:
	_model = model.duplicate(true)
	_layout = layout.duplicate(true)
	_font = font
	if is_node_ready():
		_build()


func _ready() -> void:
	_build()


func _build() -> void:
	if _layout.is_empty() or _model.is_empty():
		return
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.35)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var panel := PanelContainer.new()
	var b: Array = _layout.bounds
	panel.position = Vector2(b[0], b[1])
	panel.size = Vector2(b[2], b[3])
	var style := StyleBoxFlat.new()
	style.bg_color = Color(_layout.color)
	style.set_content_margin_all(24)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", _layout.row_spacing)
	panel.add_child(column)
	var title := Label.new()
	title.text = _model.title
	_decorate(title)
	column.add_child(title)
	var tabs := HBoxContainer.new()
	column.add_child(tabs)
	for tab: Dictionary in _model.tabs:
		var button := _button(tab.text)
		button.autowrap_mode = TextServer.AUTOWRAP_OFF
		button.custom_minimum_size.x = _font.get_string_size(tab.text, HORIZONTAL_ALIGNMENT_LEFT, -1, _layout.tab_size).x + _layout.tab_padding
		button.add_theme_font_size_override("font_size", _layout.tab_size)
		button.pressed.connect(func() -> void: section_requested.emit(tab.id))
		tabs.add_child(button)
	var message := Label.new()
	message.text = _model.message
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_decorate(message)
	column.add_child(message)
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(_scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", _layout.row_spacing)
	_scroll.add_child(_content)
	for row: Dictionary in _model.rows:
		if row.has("command"):
			var button := _button(row.text)
			button.pressed.connect(func() -> void: command_requested.emit(row.command.duplicate(true)))
			button.focus_entered.connect(func() -> void: _scroll.ensure_control_visible(button))
			_content.add_child(button)
		else:
			var label := Label.new()
			label.text = row.text
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			_decorate(label)
			_content.add_child(label)
	var close := _button(_model.close)
	close.pressed.connect(func() -> void: close_requested.emit())
	column.add_child(close)
	close.grab_focus()


func present(reduced: bool) -> void:
	_reduced = reduced
	if _motion:
		_motion.kill()
	modulate.a = 1.0 if reduced else 0.0
	if not reduced:
		_motion = create_tween()
		_motion.tween_property(self, "modulate:a", 1.0, _layout.enter_duration)


func _button(value: String) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 42
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_decorate(button)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(_layout.button_color if state == "normal" else _layout.highlight_color)
		style.border_color = Color(_layout.accent_color)
		style.set_border_width_all(1)
		style.set_content_margin_all(8)
		button.add_theme_stylebox_override(state, style)
	for state: String in ["hover", "pressed", "focus"]:
		button.add_theme_color_override("font_" + state + "_color", Color(_layout.ink))
	return button


func _decorate(control: Control) -> void:
	control.add_theme_font_override("font", _font)
	control.add_theme_font_size_override("font_size", _layout.font_size)
	control.add_theme_color_override("font_color", Color(_layout.ink))
