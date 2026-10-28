extends Node2D
## Time-of-day light for a side room: CanvasModulate tint, one additive sun
## shaft sprite, at most MAX_RUNTIME_LIGHTS PointLight2D (excess preset lights
## are ignored), water-layer tint and a full-screen grade on a CanvasLayer
## below the UI. apply() blends from the state captured by show_phase().

const RULES = preload("res://src/shared/side_room_rules.gd")
const LAYERS = preload("res://src/world/side/side_layers.gd")
const GRADE_SHADER = preload("res://src/world/side/side_grade.gdshader")
const WATER_SHADER = preload("res://src/world/side/side_water.gdshader")
const MAX_RUNTIME_LIGHTS := RULES.MAX_RUNTIME_LIGHTS
## Above every authored layer behind the play plane, below the prop band.
const SHAFT_Z := LAYERS.ACTOR_Z - LAYERS.PROP_BAND - 1
## The main world canvas is layer 0; this canvas sorts after it (later child)
## and below the default UI CanvasLayer (layer 1).
const GRADE_LAYER := 0
const LIGHT_TEXTURE_RADIUS := 128.0
const WATER_STRENGTH := 0.6

## True when shaft sway and water ripples advance (high quality, full motion).
var animated := true
var tween: Tween
var _water_shader := true
var _time := 0.0
var _canvas: CanvasModulate
var _shaft: Sprite2D
var _grade: CanvasLayer
var _lights: Array[PointLight2D] = []
var _water: Array[CanvasItem] = []
var _water_material: ShaderMaterial
var _from: Dictionary = {}
var _state: Dictionary = {}


func configure(bounds: Dictionary, height: float, water_items: Array) -> void:
	_canvas = CanvasModulate.new()
	_canvas.name = "TimeOfDay"
	add_child(_canvas)
	_shaft = Sprite2D.new()
	_shaft.name = "SunShaft"
	_shaft.texture = _gradient(GradientTexture2D.FILL_RADIAL, Vector2(0.5, 0.0), Vector2(0.5, 1.0))
	_shaft.offset = Vector2(0.0, LIGHT_TEXTURE_RADIUS)
	_shaft.scale = Vector2(height * 0.5, height * 1.4) / (2.0 * LIGHT_TEXTURE_RADIUS)
	_shaft.position = Vector2(lerpf(float(bounds.min_x), float(bounds.max_x), 0.5), 0.0)
	_shaft.material = CanvasItemMaterial.new()
	_shaft.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_shaft.z_index = SHAFT_Z
	add_child(_shaft)
	_water_material = ShaderMaterial.new()
	_water_material.shader = WATER_SHADER
	_water_material.set_shader_parameter("strength", WATER_STRENGTH)
	for item: CanvasItem in water_items:
		_water.append(item)
	_grade = CanvasLayer.new()
	_grade.name = "Grade"
	_grade.layer = GRADE_LAYER
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.material = ShaderMaterial.new()
	rect.material.shader = GRADE_SHADER
	_grade.add_child(rect)
	add_child(_grade)
	_apply_water_mode()


## Quality "high" animates the shaft and keeps the water shader; reduced
## motion freezes motion but keeps the shader with a still surface.
func set_modes(high_quality: bool, reduced: bool) -> void:
	animated = high_quality and not reduced
	_water_shader = high_quality
	_apply_water_mode()
	_render()


## Blends from the displayed state to preset over seconds (0 = immediate).
func show_phase(preset: Dictionary, seconds: float) -> void:
	if tween:
		tween.kill()
		tween = null
	_from = _state.duplicate(true)
	if seconds <= 0.0:
		apply(preset, 1.0)
		return
	tween = create_tween()
	tween.tween_method(func(blend: float) -> void: apply(preset, blend), 0.0, 1.0, seconds)


func is_transitioning() -> bool:
	return tween != null and tween.is_running()


func apply(preset: Dictionary, blend: float) -> void:
	var target := _resolve(preset)
	if _from.is_empty():
		_from = target
	var t := clampf(blend, 0.0, 1.0)
	_state = {
		"modulate": (_from.modulate as Color).lerp(target.modulate, t),
		"sun_color": (_from.sun_color as Color).lerp(target.sun_color, t),
		"sun_energy": lerpf(_from.sun_energy, target.sun_energy, t),
		"sun_angle": lerpf(_from.sun_angle, target.sun_angle, t),
		"water": (_from.water as Color).lerp(target.water, t),
		"lights": [],
	}
	for index: int in MAX_RUNTIME_LIGHTS:
		var a: Dictionary = _from.lights[index]
		var b: Dictionary = target.lights[index]
		var lit: Dictionary = b if b.energy > 0.0 else a
		_state.lights.append({
			"position": lit.position, "color": (a.color as Color).lerp(b.color, t),
			"energy": lerpf(a.energy, b.energy, t), "radius": lerpf(a.radius, b.radius, t),
		})
	if t >= 1.0:
		_from = _state.duplicate(true)
	_render()


func _process(delta: float) -> void:
	if not animated or _state.is_empty():
		return
	_time += delta
	_render()


func _resolve(preset: Dictionary) -> Dictionary:
	var sun: Dictionary = preset.sun
	var resolved := {
		"modulate": Color.html(str(preset.modulate)), "sun_color": Color.html(str(sun.color)),
		"sun_energy": float(sun.energy), "sun_angle": float(sun.angle),
		"water": Color.html(str(preset.water_tint)), "lights": [],
	}
	var authored: Array = preset.lights
	for index: int in MAX_RUNTIME_LIGHTS:
		var light: Dictionary = authored[index] if index < authored.size() else {}
		var point: Array = light.get("position", [0.0, 0.0])
		resolved.lights.append({
			"position": Vector2(float(point[0]), float(point[1])),
			"color": Color.html(str(light.get("color", "#000000"))),
			"energy": float(light.get("energy", 0.0)), "radius": float(light.get("radius", 1.0)),
		})
	return resolved


func _render() -> void:
	if _state.is_empty():
		return
	_canvas.color = _state.modulate
	var sway := sin(_time * 0.35) if animated else 0.0
	_shaft.rotation = deg_to_rad(_state.sun_angle + sway * 1.5)
	var color: Color = _state.sun_color
	color.a = clampf(_state.sun_energy * (1.0 + sway * 0.08), 0.0, 1.0)
	_shaft.modulate = color
	_shaft.visible = _state.sun_energy > 0.001
	for index: int in MAX_RUNTIME_LIGHTS:
		var spec: Dictionary = _state.lights[index]
		if spec.energy <= 0.001 and index >= _lights.size():
			continue
		var light := _light(index)
		light.position = spec.position
		light.color = spec.color
		light.energy = spec.energy
		light.texture_scale = maxf(spec.radius, 1.0) / LIGHT_TEXTURE_RADIUS
		light.enabled = spec.energy > 0.001
	var tint: Color = _state.water
	_water_material.set_shader_parameter("tint", tint)
	_water_material.set_shader_parameter("wave_time", _time)
	for item: CanvasItem in _water:
		item.self_modulate = Color.WHITE if _water_shader else Color.WHITE.lerp(tint, WATER_STRENGTH)


func _apply_water_mode() -> void:
	for item: CanvasItem in _water:
		item.material = _water_material if _water_shader else null


func _light(index: int) -> PointLight2D:
	while _lights.size() <= index:
		var light := PointLight2D.new()
		light.name = "Light_%d" % _lights.size()
		light.texture = _gradient(GradientTexture2D.FILL_RADIAL, Vector2(0.5, 0.5), Vector2(1.0, 0.5))
		light.blend_mode = Light2D.BLEND_MODE_ADD
		add_child(light)
		_lights.append(light)
	return _lights[index]


static func _gradient(fill: int, from: Vector2, to: Vector2) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = fill
	texture.fill_from = from
	texture.fill_to = to
	var size := int(LIGHT_TEXTURE_RADIUS * 2.0)
	texture.width = size
	texture.height = size
	return texture
