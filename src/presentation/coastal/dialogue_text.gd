extends Control
## Retains the authored Label as the settled surface; temporary passes reveal ink.

signal completed

const INK = preload("res://src/presentation/coastal/dialogue_ink.gd")
const BLUR = preload("res://src/presentation/coastal/dialogue_blur.gdshader")

var _source: Label
var _sharp: RichTextLabel
var _soft: RichTextLabel
var _viewport: SubViewport
var _surface: TextureRect
var _sharp_ink: RichTextEffect
var _soft_ink: RichTextEffect
var _settings: Dictionary
var _clock := 0.0
var _end := 0.0
var revealing := false


func configure(source: Label, settings: Dictionary) -> void:
	_source = source
	_settings = settings
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sharp_ink = INK.new()
	_soft_ink = INK.new()
	_soft_ink.soft = true
	_sharp = _pass(_sharp_ink)
	_sharp.position = source.position
	add_child(_sharp)
	_viewport = SubViewport.new()
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.gui_disable_input = true
	var padding := float(settings.blur_padding)
	_viewport.size = Vector2i(source.size + Vector2.ONE * padding * 2.0)
	add_child(_viewport)
	_soft = _pass(_soft_ink)
	_soft.position = Vector2.ONE * padding
	_viewport.add_child(_soft)
	_surface = TextureRect.new()
	_surface.position = source.position - Vector2.ONE * padding
	_surface.size = Vector2(_viewport.size)
	_surface.texture = _viewport.get_texture()
	_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = BLUR
	material.set_shader_parameter("radius", settings.blur_radius)
	_surface.material = material
	add_child(_surface)
	stop()


func _pass(effect: RichTextEffect) -> RichTextLabel:
	var node := RichTextLabel.new()
	node.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	node.size = _source.size
	node.scroll_active = false
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.autowrap_mode = _source.autowrap_mode
	node.add_theme_font_override("normal_font", _source.get_theme_font("font"))
	node.add_theme_font_size_override("normal_font_size", _source.get_theme_font_size("font_size"))
	node.add_theme_color_override("default_color", _source.get_theme_color("font_color"))
	node.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	node.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	node.add_theme_constant_override("line_separation", _source.get_theme_constant("line_spacing"))
	node.install_effect(effect)
	return node


func start(reduced: bool) -> void:
	stop()
	_clock = 0.0
	var arrivals := schedule(_source.text, _settings)
	_end = (arrivals[-1] + float(_settings.soft_duration)) if not arrivals.is_empty() else 0.0
	for effect: RichTextEffect in [_sharp_ink, _soft_ink]:
		effect.arrivals = arrivals
		effect.duration = _settings.soft_duration
		effect.clock = _clock
	for label: RichTextLabel in [_sharp, _soft]:
		label.process_mode = Node.PROCESS_MODE_INHERIT
		label.clear()
		label.push_customfx(_soft_ink if label == _soft else _sharp_ink, {})
		label.add_text(_source.text)
		label.pop()
	revealing = true
	_source.visible = false
	visible = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	set_process(true)
	if reduced or _end == 0.0:
		finish()


static func schedule(value: String, settings: Dictionary) -> PackedFloat32Array:
	var arrivals := PackedFloat32Array()
	arrivals.resize(value.length())
	var start := 0
	var at := 0.0
	# Composite boundaries keep Vietnamese combining marks with their base character.
	for end: int in TextServerManager.get_primary_interface().string_get_character_breaks(value):
		for index: int in range(start, end):
			arrivals[index] = at
		var cluster := value.substr(start, end - start)
		at += 1.0 / float(settings.characters_per_second)
		at += float(settings.punctuation_pauses.get(cluster, 0.0))
		start = end
	return arrivals


func _process(delta: float) -> void:
	_clock += delta
	_sharp_ink.clock = _clock
	_soft_ink.clock = _clock
	if _clock >= _end:
		finish()


func finish() -> void:
	if not revealing:
		return
	stop()
	completed.emit()


func pause() -> void:
	# Closing preserves the current partial sentence instead of flashing unread text.
	if revealing:
		revealing = false
		set_process(false)
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		for label: RichTextLabel in [_sharp, _soft]:
			label.process_mode = Node.PROCESS_MODE_DISABLED


func stop() -> void:
	revealing = false
	set_process(false)
	visible = false
	if _source:
		_source.visible = true
	if _viewport:
		_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	for label: RichTextLabel in [_sharp, _soft]:
		if label:
			label.process_mode = Node.PROCESS_MODE_DISABLED
