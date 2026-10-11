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
	settings.tonemap_exposure = config.ambient.get("exposure", 1.0)
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
	for item: Dictionary in config.get("local_lights", []):
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(item.position[0], item.position[1], item.position[2])
		lamp.light_color = Color(item.color)
		lamp.light_energy = item.energy
		lamp.omni_range = item.range
		lamp.shadow_enabled = false
		parent.add_child(lamp)


static func camera_attributes(camera: Camera3D, config: Dictionary) -> void:
	if not config.get("atmosphere", {}).has("dof"):
		return
	var dof: Dictionary = config.atmosphere.dof
	var attributes := CameraAttributesPractical.new()
	attributes.dof_blur_far_enabled = true
	attributes.dof_blur_far_distance = dof.get("far_distance", dof.get("distance", 27.0))
	attributes.dof_blur_far_transition = dof.get("far_transition", dof.get("transition", 5.0))
	attributes.dof_blur_amount = dof.get("amount", 0.1)
	attributes.dof_blur_near_enabled = dof.has("near_distance")
	attributes.dof_blur_near_distance = dof.get("near_distance", 0.0)
	attributes.dof_blur_near_transition = dof.get("near_transition", 2.0)
	camera.attributes = attributes
