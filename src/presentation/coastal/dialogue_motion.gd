extends Node
## Owns structural tweens and ambient phase; text and choice focus have separate owners.

const WAVE = preload("res://src/presentation/coastal/dialogue_wave.gdshader")

var _layers: Dictionary
var _settings: Dictionary
var _wave: ShaderMaterial
var _tween: Tween
var _clock := 0.0
var _ambient := false
var _reduced := false


func configure(layers: Dictionary, settings: Dictionary) -> void:
	_layers = layers
	_settings = settings
	_wave = ShaderMaterial.new()
	_wave.shader = WAVE
	var idle: Dictionary = settings.idle
	_wave.set_shader_parameter("period", idle.wave_period)
	_wave.set_shader_parameter("secondary_period", idle.secondary_period)
	_wave.set_shader_parameter("frequency", idle.wave_frequency)
	_wave.set_shader_parameter("secondary_amplitude", idle.secondary_amplitude)
	_wave.set_shader_parameter("shimmer_strength", idle.shimmer_strength)
	_wave.set_shader_parameter("shimmer_width", idle.shimmer_width)
	_layers.wave.get_child(0).material = _wave
	set_process(false)


func open(reduced: bool, begin_text: Callable) -> void:
	stop()
	_reduced = reduced
	if reduced:
		settle()
		begin_text.call()
		return
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for id: String in _settings.opening:
		var node: Control = _layers[id]
		var spec: Dictionary = _settings.opening[id]
		node.modulate.a = 0.0
		node.position = Vector2(spec.offset[0], spec.offset[1])
		node.rotation = deg_to_rad(spec.rotation)
		_tween.tween_property(node, "modulate:a", 1.0, spec.duration).set_delay(spec.delay)
		_tween.tween_property(node, "position", Vector2.ZERO, spec.duration).set_delay(spec.delay)
		_tween.tween_property(node, "rotation", 0.0, spec.duration).set_delay(spec.delay)
	_tween.tween_callback(begin_text).set_delay(_settings.text_delay)
	_tween.chain().tween_callback(_start_ambient)


func settle() -> void:
	if _tween:
		_tween.kill()
	for id: String in _settings.opening:
		_layers[id].position = Vector2.ZERO
		_layers[id].rotation = 0.0
		_layers[id].modulate.a = 1.0
	_start_ambient()


func close(finished: Callable) -> void:
	stop()
	if _reduced:
		finished.call()
		return
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	for id: String in _settings.closing:
		if id == "choices":
			_layers.choices.close_rows()
			continue
		var spec: Dictionary = _settings.closing[id]
		var node: Control = _layers[id]
		var opening: Dictionary = _settings.opening.get(id, {"offset": _settings.choices.offset, "rotation": 0})
		_tween.tween_property(node, "modulate:a", 0.0, spec.duration).set_delay(spec.delay)
		_tween.tween_property(node, "position", Vector2(opening.offset[0], opening.offset[1]), spec.duration).set_delay(spec.delay)
		_tween.tween_property(node, "rotation", deg_to_rad(opening.rotation), spec.duration).set_delay(spec.delay)
	_tween.chain().tween_callback(finished)


func _start_ambient() -> void:
	_ambient = not _reduced
	set_process(_ambient)
	_wave.set_shader_parameter("amplitude", _settings.idle.wave_amplitude if _ambient else 0.0)


func _process(delta: float) -> void:
	_clock += delta
	var idle: Dictionary = _settings.idle
	_wave.set_shader_parameter("phase", _clock)
	_layers.flowers.rotation = deg_to_rad(idle.flowers_degrees) * sin(_clock * TAU / idle.flowers_period)
	if _layers.proceed.visible:
		_layers.proceed.modulate.a = lerpf(idle.proceed_min_alpha, 1.0, (cos(_clock * TAU / idle.proceed_period) + 1.0) / 2.0)


func stop() -> void:
	if _tween:
		_tween.kill()
	_ambient = false
	set_process(false)
	if _wave:
		_wave.set_shader_parameter("amplitude", 0.0)
	if not _layers.is_empty():
		_layers.flowers.rotation = 0.0
		_layers.proceed.modulate.a = 1.0
