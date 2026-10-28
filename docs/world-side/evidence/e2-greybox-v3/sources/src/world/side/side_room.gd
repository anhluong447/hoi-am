extends Node2D
## Side-scroll room: builds layers/props/actors from injected room data and
## emits stable target/door/location IDs. Mirrors the 3D room contract used by
## playable composition; owns no session, calendar or save state.

signal interaction_requested(target_id: String)
signal portal_requested(location_id: String, spawn_id: String)
signal door_requested(room_id: String, spawn_id: String)
signal menu_requested
signal nearby_changed(target_id: String)

const KIND := "side_room_v1"
const ACTOR = preload("res://src/world/side/side_actor.tscn")
const CAMERA = preload("res://src/world/side/side_camera.gd")
const LAYERS = preload("res://src/world/side/side_layers.gd")
const TARGETS = preload("res://src/world/side/side_targets.gd")
const DOORS = preload("res://src/world/side/side_doors.gd")
const MOTION = preload("res://src/world/side/side_motion.gd")
const LIGHTING = preload("res://src/world/side/side_lighting.gd")
const ATMOSPHERE = preload("res://src/world/side/side_atmosphere.gd")
const VALIDATION = preload("res://src/shared/side_room_validation.gd")
const PHASE_SECONDS := 1.5

var player: Node2D
var camera: Camera2D
## "high": shaft motion, dust, water shader; "low": static shaft/water only.
var quality := "high"
var lighting: Node2D
var atmosphere: Node2D

var _config: Dictionary
var _actors: Dictionary
var _textures: Dictionary
var _tuning: Dictionary
var _npcs: Dictionary = {}
var _markers: Dictionary = {}
var _input_enabled := true
var _reduced := false
var _nearby := ""
var _layers: Node2D
var _light_phase := "sang"


func configure(config: Dictionary, actors: Dictionary, textures: Dictionary) -> void:
	_config = config.duplicate(true)
	_actors = actors.duplicate(true)
	_textures = textures
	_tuning = _config.get("tuning", {})


func _ready() -> void:
	assert(_config.get("kind") == KIND, "Side room must be configured by composition")
	var manifest: Dictionary = _config.manifest
	var floor_y := float(_config.floor_y)
	var height := float(_config.tuning.actor_height)
	_layers = _group("Layers")
	LAYERS.build(_layers, _config.layers, _textures, manifest)
	LAYERS.build_props(_group("Props"), _config.props, _textures, manifest, floor_y)
	var actors := _group("Actors")
	for definition: Dictionary in _config.actors:
		assert(_actors.has(definition.actor_ref), "Side room actor_ref must exist in actor definitions")
		var npc: Node2D = ACTOR.instantiate()
		npc.name = str(definition.id)
		npc.configure(null, height, _tuning)
		npc.position = Vector2(float(definition.x), floor_y)
		npc.z_index = LAYERS.ACTOR_Z
		actors.add_child(npc)
		npc.face(int(definition.facing))
		_npcs[definition.id] = npc
	player = ACTOR.instantiate()
	player.name = "Player"
	player.configure(null, height, _tuning)
	player.z_index = LAYERS.ACTOR_Z
	actors.add_child(player)
	_markers = DOORS.build_targets(_group("Targets"), _config.interactions, _config.doors, floor_y, height)
	camera = CAMERA.new()
	camera.name = "Camera"
	add_child(camera)
	camera.configure(_config.bounds, float(_config.height), _tuning)
	camera.make_current()
	place_player(str(_config.default_spawn))
	_mount_environment()


func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right") if _input_enabled else 0.0
	if _input_enabled:
		player.move(axis, delta, _config.bounds)
	camera.follow(player.position.x, delta, _reduced)
	var nearest := DOORS.nearby(_config.interactions, _config.doors, player.position.x) if _input_enabled else ""
	if nearest != _nearby:
		_nearby = nearest
		nearby_changed.emit(nearest)


func _process(_delta: float) -> void:
	_scroll_layers()


func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	if event.is_action_pressed("interact"):
		if _nearby.is_empty():
			return
		var door := TARGETS.find(_config.doors, _nearby)
		if door.is_empty():
			interaction_requested.emit(_nearby)
		elif door.has("target_room"):
			door_requested.emit(str(door.target_room), str(door.target_spawn))
		else:
			portal_requested.emit(str(door.get("target_location", "")), str(door.target_spawn))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu"):
		menu_requested.emit()
		get_viewport().set_input_as_handled()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if player and not enabled:
		player.stop()


func place_player(spawn_id: String, x: float = NAN, facing: int = 0) -> void:
	var spawns: Dictionary = _config.spawns
	var spawn: Dictionary = spawns.get(spawn_id, spawns[_config.default_spawn])
	var bounds: Dictionary = _config.bounds
	var target_x := float(spawn.x)
	if is_finite(x) and x >= float(bounds.min_x) and x <= float(bounds.max_x):
		target_x = x
	player.position = Vector2(safe_spawn_x(target_x), float(_config.floor_y))
	player.stop()
	player.face(facing if facing == 1 or facing == -1 else int(spawn.facing))
	camera.snap(player.position.x)
	_scroll_layers()


func safe_spawn_x(x: float) -> float:
	var value := x if is_finite(x) else float(_config.spawns[_config.default_spawn].x)
	return MOTION.clamp_x(value, _config.bounds, float(_tuning.get("actor_half_width", 40.0)))


func target_label_key(id: String) -> String:
	var key := str(TARGETS.find(_config.interactions, id).get("label_key", ""))
	return key if not key.is_empty() else DOORS.label_key(_config.doors, id)


func accepts_saved_room(id: String) -> bool:
	return id == _config.id


func anchor_for(id: String) -> Dictionary:
	if not _markers.has(id):
		return {"visible": false}
	var screen: Vector2 = _markers[id].get_global_transform_with_canvas().origin
	var inside := get_viewport().get_visible_rect().has_point(screen)
	return {"visible": inside, "position": screen}


func set_actor_talking(id: String, talking: bool) -> void:
	if not _npcs.has(id):
		return
	var npc: Node2D = _npcs[id]
	if talking:
		npc.face(1 if player.position.x >= npc.position.x else -1)
		return
	for definition: Dictionary in _config.actors:
		if definition.id == id:
			npc.face(int(definition.facing))


func set_quality(id: String) -> void:
	quality = id
	_apply_modes()


func set_reduced_motion(reduced: bool) -> void:
	_reduced = reduced
	_apply_modes()
	if reduced and lighting and lighting.is_transitioning():
		_show_phase(false)


## Domain phase id -> lighting phase via the injected phase_map. Before mount
## it only selects the starting light; unmapped phases keep the current one.
func set_lighting_phase(phase_id: String) -> void:
	var mapped := str(_config.get("phase_map", {}).get(phase_id, ""))
	if not _config.get("lighting", {}).get("phases", {}).has(mapped):
		return
	_light_phase = mapped
	if lighting:
		_show_phase(not _reduced)


func _mount_environment() -> void:
	var preset: Dictionary = _config.get("lighting", {})
	if preset.is_empty():
		return
	assert(VALIDATION.validate_lighting(preset).ok, "Side room lighting must be a valid preset")
	lighting = LIGHTING.new()
	lighting.name = "Lighting"
	add_child(lighting)
	lighting.configure(_config.bounds, float(_config.height), LAYERS.water_items(_layers, _config.layers))
	atmosphere = ATMOSPHERE.new()
	atmosphere.name = "Atmosphere"
	atmosphere.z_index = LIGHTING.SHAFT_Z
	add_child(atmosphere)
	var spec: Dictionary = _config.bounds.merged({"height": _config.height})
	atmosphere.configure(spec, hash(str(_config.id)))
	_apply_modes()
	_show_phase(false)


func _apply_modes() -> void:
	if not lighting:
		return
	lighting.set_modes(quality == "high", _reduced)
	atmosphere.set_enabled(quality == "high")
	atmosphere.set_reduced_motion(_reduced)


func _show_phase(animate: bool) -> void:
	var phase: Dictionary = _config.lighting.phases[_light_phase]
	atmosphere.set_density(float(phase.dust))
	lighting.show_phase(phase, PHASE_SECONDS if animate else 0.0)


func _scroll_layers() -> void:
	LAYERS.scroll(_layers, camera.left_edge(), float(_config.bounds.min_x))


func _group(group_name: String) -> Node2D:
	var node := Node2D.new()
	node.name = group_name
	add_child(node)
	return node
