extends RefCounted
## Concrete primitives shared by the two coastal views; no gameplay dependencies.


static func rectangle(bounds: Array) -> Rect2:
	return Rect2(bounds[0], bounds[1], bounds[2], bounds[3])


static func art(parent: Control, texture: Texture2D, bounds: Array) -> TextureRect:
	var node := TextureRect.new()
	node.position = rectangle(bounds).position
	node.size = rectangle(bounds).size
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_SCALE
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


static func copy(parent: Control, value: String, spec: Dictionary, font: Font) -> Label:
	var node := Label.new()
	node.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	if spec.has("width"):
		node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.text = value
	var font_size: int = roundi(spec.get("size", 24))
	node.add_theme_font_override("font", font)
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", Color(spec.get("fill", "#16152f")))
	node.position = Vector2(spec.x, spec.y - font.get_ascent(font_size))
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	if spec.has("width"):
		node.size = Vector2(spec.width, spec.get("height", 120))
	return node


static func target(parent: Control, bounds: Array, accessible_text: String) -> Button:
	var node := Button.new()
	node.position = rectangle(bounds).position
	node.size = rectangle(bounds).size
	node.flat = true
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.accessibility_name = accessible_text
	var transparent := StyleBoxEmpty.new()
	for state: String in ["normal", "hover", "pressed"]:
		node.add_theme_stylebox_override(state, transparent)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("#087185")
	focus.set_border_width_all(2)
	node.add_theme_stylebox_override("focus", focus)
	parent.add_child(node)
	return node
