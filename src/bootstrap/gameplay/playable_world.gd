extends RefCounted
## Location/room navigation and the world part of gameplay saves for Playable.
## Locations either name one HD-2D room pack or a side-scroll entry room.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const ROOMS = preload("res://src/bootstrap/gameplay/playable_rooms.gd")
const LOCATIONS_PATH := "res://content/world/locations.json"
const FALLBACK_LOCATION := "club"
const SIDE_KIND := "side"


## Mounts a location without touching modals (also used before the HUD exists).
static func mount_location(play: Node, location_id: String, spawn_id: String = "travel") -> bool:
	var locations := _locations()
	if not locations.has(location_id):
		location_id = FALLBACK_LOCATION
	if not locations.has(location_id):
		return false
	var definition: Dictionary = locations[location_id]
	if definition.get("kind") == SIDE_KIND:
		return _mount_side(play, definition.rooms_path, str(definition.entry_room), spawn_id, location_id)
	var config := LOADER.read_dictionary(definition.room_path)
	if not config.ok or not ROOMS.mount(play, config.data):
		return false
	play._room_id = definition.room_id
	play.controller.location_id = location_id
	return true


static func travel(play: Node, location_id: String, spawn_id: String = "travel") -> void:
	mount_location(play, location_id, spawn_id)
	play.close_modal()


## Enters a side room by id; the room's authored location_id becomes current.
static func enter_room(play: Node, room_id: String, spawn_id: String) -> void:
	var locations := _locations()
	var current: Dictionary = locations.get(play.controller.location_id, {})
	var room := _side_room(locations, current, room_id)
	if not room.is_empty():
		_mount_side(play, current.rooms_path, room_id, spawn_id, room.location_id)


## World envelope v2: side rooms keep x/facing, HD-2D rooms keep position.
static func snapshot(play: Node) -> Dictionary:
	var world := {"version": 2, "location_id": play.controller.location_id, "room_id": play._room_id}
	if _is_side(play.room):
		world.x = play.room.player.position.x
		world.facing = play.room.player.facing
	else:
		var p: Vector3 = play.room.player.position
		world.position = [p.x, p.y, p.z]
	return world


## v2 side saves re-enter their room at the saved x (out-of-bounds x uses the
## room default spawn); v1 and old HD-2D rooms of now-side locations use the
## location travel spawn. HD-2D positions restore through safe_spawn.
static func restore(play: Node, world: Dictionary) -> void:
	if world.has("x") and _restore_side(play, world):
		play.close_modal()
		return
	travel(play, world.location_id)
	if _is_side(play.room):
		play._refresh()
		return
	play.room.set_input_enabled(false)
	await play.get_tree().physics_frame
	if not play.is_inside_tree():
		return
	var compatible: bool = world.room_id == play._room_id or play.room.accepts_saved_room(world.room_id)
	var position: Array = world.get("position", [INF, INF, INF]) if compatible else [INF, INF, INF]
	play.room.player.position = play.room.safe_spawn(Vector3(position[0], position[1], position[2]))
	play.room.player.velocity = Vector3.ZERO
	play.room.set_input_enabled(play.controller.modal.is_empty())
	play._refresh()


static func _restore_side(play: Node, world: Dictionary) -> bool:
	var locations := _locations()
	var location: Dictionary = locations.get(world.location_id, {})
	var room := _side_room(locations, location, world.room_id)
	if room.get("location_id") != world.location_id:
		return false
	var spawn := str(room.default_spawn)
	return _mount_side(play, location.rooms_path, world.room_id, spawn, world.location_id, float(world.x), int(world.facing))


## Room data for `room_id` when it lives in `from`'s side rooms_path and names a
## side location sharing that path; empty otherwise.
static func _side_room(locations: Dictionary, from: Dictionary, room_id: String) -> Dictionary:
	if from.get("kind") != SIDE_KIND or not room_id.is_valid_identifier():
		return {}
	var room := LOADER.read_dictionary(str(from.rooms_path).path_join(room_id + ".json"))
	var data: Dictionary = room.get("data", {})
	var target: Dictionary = locations.get(str(data.get("location_id", "")), {})
	if not room.ok or target.get("kind") != SIDE_KIND or target.rooms_path != from.rooms_path:
		return {}
	return data


static func _mount_side(play: Node, rooms_path: String, room_id: String, spawn_id: String, location_id: String, x: float = NAN, facing: int = 0) -> bool:
	if not ROOMS.mount(play, {"kind": ROOMS.SIDE_KIND, "id": room_id}, rooms_path):
		return false
	play._room_id = room_id
	play.controller.location_id = location_id
	play.room.place_player(spawn_id, x, facing)
	return true


static func _is_side(room: Node) -> bool:
	return room.has_method("safe_spawn_x")


static func _locations() -> Dictionary:
	var loaded := LOADER.read_dictionary(LOCATIONS_PATH)
	return loaded.data.get("locations", {}) if loaded.ok else {}
