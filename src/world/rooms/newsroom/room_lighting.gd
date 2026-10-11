extends RefCounted
## Room-owned lighting composition; no session or persistence access.


static func build(parent: Node3D, config: Dictionary) -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color(config.ambient.background)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color(config.ambient.color)
	settings.ambient_light_energy = config.ambient.energy
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = settings
	parent.add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.name = "WindowSun"
	sun.rotation_degrees = Vector3(config.sun.rotation[0], config.sun.rotation[1], config.sun.rotation[2])
	sun.light_color = Color(config.sun.color)
	sun.light_energy = config.sun.energy
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = config.sun.shadow_distance
	sun.shadow_normal_bias = config.sun.normal_bias
	parent.add_child(sun)
