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
const MOTION = preload("res://src/world/side/side_motion.gd")

var player: Node2D
var camera: Camera2D
## Last quality id from composition; Task 6 lighting/atmosphere scale with it.
var quality := "high"

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
	var markers := _group("Targets")
	for definition: Dictionary in _config.interactions:
		var marker := Node2D.new()
		marker.name = str(definition.id)
		marker.position = Vector2(float(definition.x), float(definition.anchor_y))
		markers.add_child(marker)
		_markers[definition.id] = marker
	camera = CAMERA.new()
	camera.name = "Camera"
	add_child(camera)
	camera.configure(_config.bounds, float(_config.height), _tuning)
	camera.make_current()
	place_player(str(_config.default_spawn))


func _physics_process(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right") if _input_enabled else 0.0
	if _input_enabled:
		player.move(axis, delta, _config.bounds)
	camera.follow(player.position.x, delta, _reduced)
	var nearest := TARGETS.nearest(_config.interactions, player.position.x) if _input_enabled else ""
	if nearest != _nearby:
		_nearby = nearest
		nearby_changed.emit(nearest)


func _process(_delta: float) -> void:
	_scroll_layers()


func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	if event.is_action_pressed("interact"):
		if not _nearby.is_empty():
			interaction_requested.emit(_nearby)
			get_viewport().set_input_as_handled()
			return
		var door := TARGETS.find(_config.doors, TARGETS.nearest(_config.doors, player.position.x))
		if door.is_empty():
			return
		if door.has("target_location"):
			portal_requested.emit(str(door.target_location), str(door.target_spawn))
		else:
			door_requested.emit(str(door.target_room), str(door.target_spawn))
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
	return str(TARGETS.find(_config.interactions, id).get("label_key", ""))


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


func set_reduced_motion(reduced: bool) -> void:
	_reduced = reduced


func _scroll_layers() -> void:
	LAYERS.scroll(_layers, camera.left_edge(), float(_config.bounds.min_x))


func _group(group_name: String) -> Node2D:
	var node := Node2D.new()
	node.name = group_name
	add_child(node)
	return node
