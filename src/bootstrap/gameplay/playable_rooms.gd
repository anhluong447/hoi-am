extends RefCounted
## Playable owns room lifetimes; this focused composer prepares injected resources.

const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")
const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const RESOURCES = preload("res://src/bootstrap/world_resources.gd")


static func mount(play: Node, config: Dictionary) -> void:
	var prepared := RESOURCES.prepare(config, STARTUP.actor_textures(play.setup.data), play.setup.text)
	assert(prepared.ok, "World content must validate before replacing a mounted room")
	if not prepared.ok:
		return
	if is_instance_valid(play.room):
		play.get_node("World").remove_child(play.room)
		play.room.queue_free()
	play.room = ROOM.instantiate()
	play.room.configure(prepared.config, play.setup.data.actors.actors, prepared.textures)
	play.room.interaction_requested.connect(play.interact)
	play.room.nearby_changed.connect(func(id: String) -> void: play._nearby = id)
	play.room.portal_requested.connect(func(destination: String, _portal: String) -> void:
		play.room.set_input_enabled(false)
		play.travel.call_deferred(destination))
	play.room.menu_requested.connect(play.open_workspace)
	play.get_node("World").add_child(play.room)
	play.room.set_quality(play._quality)
	play.room.set_reduced_motion(play._reduced)
	play.room.set_input_enabled(play.controller.modal.is_empty())
	play._nearby = ""
