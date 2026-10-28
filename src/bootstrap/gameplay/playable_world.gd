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
	if current.get("kind") != SIDE_KIND or not room_id.is_valid_identifier():
		return
	var room := LOADER.read_dictionary(str(current.rooms_path).path_join(room_id + ".json"))
	var location_id := str(room.get("data", {}).get("location_id", ""))
	var target: Dictionary = locations.get(location_id, {})
	if not room.ok or target.get("kind") != SIDE_KIND or target.rooms_path != current.rooms_path:
		return
	_mount_side(play, target.rooms_path, room_id, spawn_id, location_id)


static func snapshot(play: Node) -> Dictionary:
	var world := {"version": 1, "location_id": play.controller.location_id, "room_id": play._room_id}
	if not _is_side(play.room):
		var p: Vector3 = play.room.player.position
		world.position = [p.x, p.y, p.z]
	return world


## Side rooms restore to the location entry room travel spawn until envelope v2.
static func restore(play: Node, world: Dictionary) -> void:
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


static func _mount_side(play: Node, rooms_path: String, room_id: String, spawn_id: String, location_id: String) -> bool:
	if not ROOMS.mount(play, {"kind": ROOMS.SIDE_KIND, "id": room_id}, rooms_path):
		return false
	play._room_id = room_id
	play.controller.location_id = location_id
	play.room.place_player(spawn_id)
	return true


static func _is_side(room: Node) -> bool:
	return room.has_method("safe_spawn_x")


static func _locations() -> Dictionary:
	var loaded := LOADER.read_dictionary(LOCATIONS_PATH)
	return loaded.data.get("locations", {}) if loaded.ok else {}
