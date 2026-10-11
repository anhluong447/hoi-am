extends Node3D

signal interaction_requested(target_id: String)
signal portal_requested(room_id: String, portal_id: String)
signal menu_requested
signal nearby_changed(target_id: String)

const GEOMETRY = preload("res://src/world/rooms/newsroom/room_geometry.gd")
const TARGET = preload("res://src/world/rooms/newsroom/interaction_target.gd")
const PLAYER = preload("res://src/world/actors/player_body.tscn")
const RIG = preload("res://src/world/actors/sprite_rig.tscn")
const ATMOSPHERE = preload("res://src/world/rooms/newsroom/room_atmosphere.gd")
const LIGHTING = preload("res://src/world/rooms/newsroom/room_lighting.gd")
const VISUALS = preload("res://src/world/rooms/newsroom/room_visuals.gd")

var player: CharacterBody3D
var camera: Camera3D
var _config: Dictionary
var _actors: Dictionary
var _textures: Dictionary
var _targets: Array = []
var _npcs: Dictionary = {}
var _input_enabled := true
var _nearby := ""
var _atmosphere: Node3D


func configure(config: Dictionary, actors: Dictionary, textures: Dictionary) -> void:
	_config = config.duplicate(true)
	_actors = actors.duplicate(true)
	_textures = textures


func _ready() -> void:
	assert(not _config.is_empty(), "Room must be configured by composition")
	var geometry := GEOMETRY.new()
	geometry.name = "Geometry"
	add_child(geometry)
	geometry.build(_config.geometry)
	if _config.has("visuals"):
		var visuals := VISUALS.new()
		visuals.name = "Visuals"
		add_child(visuals)
		visuals.build(_config.visuals, _textures.world)
	camera = Camera3D.new()
	camera.name = "Camera"
	add_child(camera)
	set_camera_preset("orthographic")
	camera.current = true
	LIGHTING.build(self, _config)
	player = PLAYER.instantiate()
	player.configure(_config, _actors.khue, _textures.khue, camera)
	player.position = GEOMETRY.vector(_config.spawn)
	add_child(player)
	for definition: Dictionary in _config.targets:
		var target := TARGET.new()
		target.name = "Target_" + str(definition.id)
		target.configure(definition)
		add_child(target)
		_targets.append(target)
	for definition: Dictionary in _config.npcs:
		var npc := RIG.instantiate()
		npc.name = "Actor_" + str(definition.id)
		npc.configure(_actors[definition.actor_id], _textures[definition.actor_id], _config.actor_pixel_size, _config.stride_world)
		npc.position = GEOMETRY.vector(definition.position)
		npc.set_direction(definition.direction)
		add_child(npc)
		_npcs[definition.id] = npc
		var body := StaticBody3D.new()
		body.position = npc.position
		var collision := CollisionShape3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = _config.collider.radius
		shape.height = _config.collider.height
		collision.shape = shape
		collision.position.y = shape.height / 2.0
		body.add_child(collision)
		add_child(body)
		npc.set_meta("body", body)
	_build_portal()
	_atmosphere = ATMOSPHERE.new()
	_atmosphere.configure(_config.get("atmosphere", {}), _textures.get("world", {}))
	add_child(_atmosphere)
	LIGHTING.camera_attributes(camera, _config)


func _physics_process(_delta: float) -> void:
	var nearest := ""
	var distance := INF
	if _input_enabled:
		for target: Area3D in _targets:
			var candidate := player.global_position.distance_squared_to(target.global_position)
			if target.player_nearby(player) and candidate < distance:
				nearest = target.target_id
				distance = candidate
	if nearest != _nearby:
		_nearby = nearest
		nearby_changed.emit(nearest)


func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	if event.is_action_pressed("interact") and not _nearby.is_empty():
		interaction_requested.emit(_nearby)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu"):
		menu_requested.emit()
		get_viewport().set_input_as_handled()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if player:
		player.set_input_enabled(enabled)


func set_camera_preset(id: String) -> void:
	var preset: Dictionary = _config.camera[id]
	camera.position = GEOMETRY.vector(preset.position)
	camera.look_at(GEOMETRY.vector(preset.target))
	camera.near = preset.near
	camera.far = preset.far
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL if id == "orthographic" else Camera3D.PROJECTION_PERSPECTIVE
	if id == "orthographic":
		camera.size = preset.size
	else:
		camera.fov = preset.fov


func safe_spawn(candidate: Vector3) -> Vector3:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = player.get_node("Collision").shape
	query.transform = Transform3D(Basis.IDENTITY, candidate + player.get_node("Collision").position)
	query.collision_mask = 1
	var in_room: bool = (
		absf(candidate.x) < _config.spawn_bounds[0]
		and absf(candidate.z) < _config.spawn_bounds[1]
		and candidate.y >= 0 and absf(candidate.y - _config.spawn[1]) <= _config.collider.height
	)
	return candidate if in_room and get_world_3d().direct_space_state.intersect_shape(query).is_empty() else GEOMETRY.vector(_config.spawn)


func target_label_key(id: String) -> String:
	for target: Dictionary in _config.targets:
		if target.id == id:
			return target.label_key
	return ""


func accepts_saved_room(id: String) -> bool:
	return id == _config.id or id in _config.get("legacy_room_ids", [])


func anchor_for(id: String) -> Dictionary:
	for target: Area3D in _targets:
		if target.target_id == id:
			var point: Vector3 = target.anchor
			if camera.is_position_behind(point):
				return {"visible": false}
			var screen := camera.unproject_position(point)
			var inside := Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size).has_point(screen)
			var query := PhysicsRayQueryParameters3D.create(camera.global_position, point, 1)
			var blocked := not get_world_3d().direct_space_state.intersect_ray(query).is_empty()
			return {"visible": inside and not blocked, "position": screen}
	return {"visible": false}


func set_actor_talking(id: String, talking: bool) -> void:
	if _npcs.has(id):
		_npcs[id].present(Vector3.ZERO, camera, talking)


func set_quality(id: String) -> void:
	_atmosphere.set_quality(id)
	get_node("WindowSun").shadow_enabled = id != "low"
	if camera.attributes:
		camera.attributes.dof_blur_far_enabled = id != "low"
		camera.attributes.dof_blur_near_enabled = id != "low" and _config.atmosphere.dof.has("near_distance")


func apply_npc_presentation(model: Array) -> void:
	for item: Dictionary in model:
		if _npcs.has(item.id):
			var npc: Node3D = _npcs[item.id]
			npc.visible = item.visible
			npc.get_meta("body").process_mode = Node.PROCESS_MODE_INHERIT if item.visible else Node.PROCESS_MODE_DISABLED
			if item.has("position"):
				npc.position = GEOMETRY.vector(item.position)
				npc.get_meta("body").position = npc.position
			npc.set_direction(item.get("direction", "down"))


func _build_portal() -> void:
	var area := Area3D.new()
	area.name = "Portal"
	area.collision_layer = 0
	area.collision_mask = 2
	area.position = GEOMETRY.vector(_config.portal.position)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = GEOMETRY.vector(_config.portal.size)
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body == player and _input_enabled:
			portal_requested.emit(_config.portal.to, _config.portal.id))
