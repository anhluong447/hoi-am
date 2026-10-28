extends RefCounted
## Playable owns room lifetimes; this focused composer prepares injected resources
## and swaps the mounted room only after the replacement validated.

const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")
const SIDE_ROOM = preload("res://src/world/side/side_room.tscn")
const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const RESOURCES = preload("res://src/bootstrap/world_resources.gd")
const SIDE_RESOURCES = preload("res://src/bootstrap/side_resources.gd")
const SIDE_KIND := "side_room_v1"


## `config` is the authored room; side rooms are loaded by id from `rooms_path`.
static func mount(play: Node, config: Dictionary, rooms_path: String = "") -> bool:
	var side: bool = config.get("kind") == SIDE_KIND
	var prepared := SIDE_RESOURCES.load_room(rooms_path, str(config.get("id", ""))) if side else RESOURCES.prepare(config, STARTUP.actor_textures(play.setup.data), play.setup.text)
	assert(prepared.ok, "World content must validate before replacing a mounted room")
	if not prepared.ok:
		return false
	if is_instance_valid(play.room):
		play.get_node("World").remove_child(play.room)
		play.room.queue_free()
	var room: Node = SIDE_ROOM.instantiate() if side else ROOM.instantiate()
	play.room = room
	room.configure(prepared.config, play.setup.data.actors.actors, prepared.textures)
	room.interaction_requested.connect(play.interact)
	room.nearby_changed.connect(func(id: String) -> void: play._nearby = id)
	room.menu_requested.connect(play.open_workspace)
	# One navigation request per mounted room: later door/portal requests from the
	# same room (or a room already replaced) are ignored until the next mount.
	var pending := [false]
	var request := func(target: Callable) -> void:
		if pending[0]:
			return
		pending[0] = true
		room.set_input_enabled(false)
		(func() -> void:
			if play.room != room:
				return
			target.call()
			if play.room == room:
				# Rejected content kept this room mounted; let it navigate again.
				pending[0] = false
				room.set_input_enabled(play.controller.modal.is_empty())).call_deferred()
	if side:
		# Doors naming a room re-derive the location from that room's content;
		# location-only doors travel to the location entry room.
		room.portal_requested.connect(func(location_id: String, spawn_id: String) -> void:
			request.call(play.travel.bind(location_id, spawn_id)))
		room.door_requested.connect(func(room_id: String, spawn_id: String) -> void:
			request.call(play.enter_room.bind(room_id, spawn_id)))
		room.set_lighting_phase(play.setup.session.snapshot().phase)
	else:
		room.portal_requested.connect(func(destination: String, _portal: String) -> void:
			request.call(play.travel.bind(destination)))
	play.get_node("World").add_child(room)
	room.set_quality(play._quality)
	room.set_reduced_motion(play._reduced)
	room.set_input_enabled(play.controller.modal.is_empty())
	play._nearby = ""
	return true
