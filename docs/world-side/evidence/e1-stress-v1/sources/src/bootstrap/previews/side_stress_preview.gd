extends Node2D
## Worst-case side-scroll render stress scene; standalone, no session or player text.

const TEXTURES = preload("res://src/bootstrap/previews/side_stress_textures.gd")
const BLUR = preload("res://src/bootstrap/previews/side_stress_blur.gdshader")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")

@export_file("*.json") var spec_path := "res://content/world2d/stress/stress_v1.json"
@export var variant_id := "hdr_glow"
var _spec := {}
var _variant := {}
var _camera: Camera2D
var _follow: Node2D
var _particles: GPUParticles2D
var _actors: Array[Sprite2D] = []
var _grid: Array[PointLight2D] = []
var _elapsed := 0.0
var _frozen := -1.0


## Stores the spec and variant; the scene is built when it enters the tree.
func configure(spec: Dictionary, variant: Dictionary) -> void:
	_spec = spec
	_variant = variant
	if is_inside_tree():
		_build()


func _ready() -> void:
	if _spec.is_empty():
		var loaded := LOADER.read_dictionary(spec_path)
		assert(loaded.ok, "Stress spec must load")
		for candidate: Dictionary in loaded.data.variants:
			if candidate.id == variant_id:
				_variant = candidate
		_spec = loaded.data
	_build()


func _build() -> void:
	get_viewport().use_hdr_2d = bool(_variant.hdr_2d)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CANVAS
	environment.glow_enabled = bool(_variant.glow)
	var tuning: Dictionary = _spec.environment
	environment.glow_intensity = tuning.glow_intensity
	environment.glow_strength = tuning.glow_strength
	environment.glow_bloom = tuning.glow_bloom
	environment.glow_hdr_threshold = tuning.glow_hdr_threshold
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var modulate_node := CanvasModulate.new()
	var probe := bool(_variant.get("probe", false))
	modulate_node.color = Color.BLACK if probe else _color(_spec.modulate.night if _variant.get("night", false) else _spec.modulate.day)
	add_child(modulate_node)
	_camera = Camera2D.new()
	add_child(_camera)
	_camera.make_current()
	_follow = Node2D.new()
	if probe:
		_frozen = 0.0
		var surface := Sprite2D.new()
		surface.texture = TEXTURES.white(64)
		surface.scale = Vector2(_spec.plate_size[0], _spec.plate_size[1]) / 64.0
		add_child(surface)
	else:
		_build_plates()
	add_child(_follow)
	if not probe:
		for light: Dictionary in _spec.lights:
			_add_light(_vec(light.offset), light.color, light.energy, light.texture_scale)
		_build_shaft()
		_build_particles()
	if _variant.has("extra_light"):
		var extra: Dictionary = _variant.extra_light
		_add_light(_vec(extra.offset), extra.color, extra.energy, extra.texture_scale)
	if probe or _variant.light_grid:
		_build_grid()
	_process(0.0)


func _build_plates() -> void:
	var size: Array = _spec.plate_size
	var mode: String = _variant.plate_import
	var plates: Array = _spec.plates
	for index in plates.size():
		if index == int(_spec.foreground_from):
			_build_actors()
		var definition: Dictionary = plates[index]
		var layer := Parallax2D.new()
		layer.scroll_scale = Vector2(definition.scroll_scale, 1.0)
		var holder: Node2D
		if definition.has("blur_lod"):
			var group := CanvasGroup.new()
			group.use_mipmaps = true
			var material := ShaderMaterial.new()
			material.shader = BLUR
			material.set_shader_parameter("lod", definition.blur_lod)
			group.material = material
			holder = group
		else:
			holder = Node2D.new()
		var texture := TEXTURES.plate(definition, size, int(_spec.noise_downsample), mode)
		for side: float in [-0.5, 0.5]:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.position = Vector2(side * float(size[0]), 0.0)
			sprite.modulate = _color(definition.tint)
			holder.add_child(sprite)
		layer.add_child(holder)
		add_child(layer)


func _build_actors() -> void:
	for definition: Dictionary in _spec.actors:
		var actor := Sprite2D.new()
		actor.texture = TEXTURES.actor(definition.size, bool(_variant.get("normal_map", true)))
		actor.position = _vec(definition.position)
		actor.modulate = _color(definition.tint)
		add_child(actor)
		_actors.append(actor)


func _add_light(offset: Vector2, color: Array, energy: float, scale_factor: float) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = TEXTURES.radial(int(_spec.light_texture_px), Color.WHITE)
	light.texture_scale = scale_factor
	light.position = offset
	light.color = _color(color)
	light.energy = energy
	light.height = float(_variant.get("light_height", 0))
	_follow.add_child(light)
	return light


func _build_grid() -> void:
	var grid: Dictionary = _spec.light_grid
	var cell := Vector2(float(_spec.plate_size[0]) / grid.columns, float(_spec.plate_size[1]) / grid.rows)
	for row in int(grid.rows):
		for column in int(grid.columns):
			var offset := Vector2((column + 0.5) * cell.x, (row + 0.5) * cell.y) - Vector2(_spec.plate_size[0], _spec.plate_size[1]) / 2.0
			_grid.append(_add_light(offset, grid.color, grid.energy, grid.texture_scale))


func _build_shaft() -> void:
	var shaft: Dictionary = _spec.sun_shaft
	var sprite := Sprite2D.new()
	sprite.texture = TEXTURES.shaft()
	sprite.scale = _vec(shaft.size) / Vector2(64.0, 256.0)
	sprite.position = _vec(shaft.offset)
	sprite.rotation_degrees = shaft.rotation_degrees
	sprite.modulate = _color(shaft.color)
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = additive
	_follow.add_child(sprite)


func _build_particles() -> void:
	var definition: Dictionary = _spec.particles
	_particles = GPUParticles2D.new()
	_particles.amount = definition.amount
	_particles.lifetime = definition.lifetime
	_particles.preprocess = definition.lifetime
	_particles.texture = TEXTURES.radial(int(definition.texture_px), Color.WHITE)
	_particles.modulate = _color(definition.color)
	if "use_fixed_seed" in _particles:
		_particles.use_fixed_seed = true
		_particles.seed = definition.seed
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(definition.extents[0], definition.extents[1], 0.0)
	process.gravity = Vector3(0.0, -6.0, 0.0)
	process.initial_velocity_min = 8.0
	process.initial_velocity_max = 24.0
	process.spread = 180.0
	process.scale_min = definition.scale
	process.scale_max = definition.scale * 2.0
	_particles.process_material = process
	_follow.add_child(_particles)


func _process(delta: float) -> void:
	_elapsed += delta
	var height := get_viewport().get_visible_rect().size.y
	_camera.zoom = Vector2.ONE * height / float(_spec.plate_size[1])
	var seconds := _frozen if _frozen >= 0.0 else _elapsed
	var pan: float = _spec.camera.pan_world_px
	_camera.position.x = pan * sin(TAU * seconds / float(_spec.camera.period_seconds))
	_follow.position = _camera.position


## Holds the camera at a fixed phase in seconds for deterministic captures.
func freeze(seconds: float, particles_visible: bool) -> void:
	_frozen = seconds
	if _particles:
		_particles.visible = particles_visible


func actor_screen_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for actor in _actors:
		var local := actor.get_rect()
		var transform := get_viewport().get_canvas_transform() * actor.get_global_transform()
		rects.append(Rect2(transform * local.position, local.size * transform.get_scale()))
	return rects


func grid_screen_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for light in _grid:
		points.append(get_viewport().get_canvas_transform() * light.global_position)
	return points


func _vec(values: Array) -> Vector2:
	return Vector2(values[0], values[1])


func _color(values: Array) -> Color:
	return Color(values[0], values[1], values[2], values[3] if values.size() > 3 else 1.0)
