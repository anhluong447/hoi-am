extends RefCounted
## Builds the additive sun shaft and dust particles for the stress scene.

const TEXTURES = preload("res://src/bootstrap/previews/side_stress_textures.gd")


static func shaft(definition: Dictionary) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = TEXTURES.shaft()
	sprite.scale = Vector2(definition.size[0], definition.size[1]) / Vector2(64.0, 256.0)
	sprite.position = Vector2(definition.offset[0], definition.offset[1])
	sprite.rotation_degrees = definition.rotation_degrees
	sprite.modulate = _color(definition.color)
	var additive := CanvasItemMaterial.new()
	additive.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = additive
	return sprite


## kind is "gpu" (GPUParticles2D) or "cpu" (CPUParticles2D) with matching motion settings.
static func dust(definition: Dictionary, kind: String) -> Node2D:
	var texture := TEXTURES.radial(int(definition.texture_px), Color.WHITE)
	var extents := Vector2(definition.extents[0], definition.extents[1])
	if kind == "cpu":
		var cpu := CPUParticles2D.new()
		cpu.amount = definition.amount
		cpu.lifetime = definition.lifetime
		cpu.preprocess = definition.lifetime
		cpu.texture = texture
		cpu.modulate = _color(definition.color)
		cpu.use_fixed_seed = true
		cpu.seed = definition.seed
		cpu.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		cpu.emission_rect_extents = extents
		cpu.gravity = Vector2(0.0, -6.0)
		cpu.initial_velocity_min = 8.0
		cpu.initial_velocity_max = 24.0
		cpu.spread = 180.0
		cpu.scale_amount_min = definition.scale
		cpu.scale_amount_max = definition.scale * 2.0
		return cpu
	var gpu := GPUParticles2D.new()
	gpu.amount = definition.amount
	gpu.lifetime = definition.lifetime
	gpu.preprocess = definition.lifetime
	gpu.texture = texture
	gpu.modulate = _color(definition.color)
	gpu.use_fixed_seed = true
	gpu.seed = definition.seed
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(extents.x, extents.y, 0.0)
	process.gravity = Vector3(0.0, -6.0, 0.0)
	process.initial_velocity_min = 8.0
	process.initial_velocity_max = 24.0
	process.spread = 180.0
	process.scale_min = definition.scale
	process.scale_max = definition.scale * 2.0
	gpu.process_material = process
	return gpu


static func _color(values: Array) -> Color:
	return Color(values[0], values[1], values[2], values[3] if values.size() > 3 else 1.0)
