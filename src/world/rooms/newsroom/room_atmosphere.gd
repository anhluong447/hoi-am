extends Node3D
## Authored harbor layers and restrained window dust; no gameplay dependencies.

const PAINT = preload("res://src/world/rooms/newsroom/painted_water.gdshader")
const SURFACE = preload("res://src/world/rooms/newsroom/coastal_water.gdshader")
const GEOMETRY = preload("res://src/world/rooms/newsroom/room_geometry.gd")

var _dust: GPUParticles3D
var _water: MeshInstance3D
var _config: Dictionary
var _resources: Dictionary
var _quality := "high"
var _reduced := false


func configure(config: Dictionary, resources: Dictionary = {}) -> void:
	_config = config.duplicate(true)
	_resources = resources


func _ready() -> void:
	if _config.is_empty():
		return
	for item: Dictionary in _config.get("harbor", []):
		var instance := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = GEOMETRY.vector(item.size)
		instance.mesh = mesh
		instance.position = GEOMETRY.vector(item.position)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(item.color)
		material.roughness = 0.95
		instance.material_override = material
		add_child(instance)
	_water = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(_config.water.size[0], _config.water.size[1])
	_water.mesh = plane
	_water.position = GEOMETRY.vector(_config.water.position)
	var water_material := ShaderMaterial.new()
	water_material.shader = PAINT if _config.water.has("asset") else SURFACE
	if _config.water.has("asset"):
		var asset: Dictionary = _resources.assets[_config.water.asset]
		var texture: Texture2D = _resources.textures[asset.atlas]
		water_material.set_shader_parameter("atlas", texture)
		water_material.set_shader_parameter("atlas_region", Vector4(asset.region[0]/float(texture.get_width()), asset.region[1]/float(texture.get_height()), asset.region[2]/float(texture.get_width()), asset.region[3]/float(texture.get_height())))
	water_material.set_shader_parameter("tint", Color(_config.water.color))
	water_material.set_shader_parameter("strength", _config.water.strength)
	water_material.set_shader_parameter("speed", _config.water.speed)
	_water.material_override = water_material
	add_child(_water)
	_dust = GPUParticles3D.new()
	_dust.amount = _config.dust.count
	_dust.lifetime = _config.dust.lifetime
	_dust.position = GEOMETRY.vector(_config.dust.position)
	_dust.visibility_aabb = AABB(Vector3(-8, -3, -8), Vector3(16, 8, 16))
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = _config.dust.radius
	particle_mesh.height = _config.dust.radius * 2
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(_config.dust.color)
	particle_mesh.material = material
	_dust.draw_pass_1 = particle_mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = GEOMETRY.vector(_config.dust.extents)
	process.gravity = GEOMETRY.vector(_config.dust.drift)
	process.initial_velocity_min = 0.02
	process.initial_velocity_max = 0.08
	_dust.process_material = process
	add_child(_dust)


func set_quality(id: String) -> void:
	_quality = id
	if _dust:
		_dust.emitting = id != "low" and not _reduced
		_dust.visible = id != "low" and not _reduced
	if _water:
		_water.material_override.set_shader_parameter("strength", 0.0 if id == "low" or _reduced else _config.water.strength)


func set_reduced_motion(reduced: bool) -> void:
	_reduced = reduced
	set_quality(_quality)
