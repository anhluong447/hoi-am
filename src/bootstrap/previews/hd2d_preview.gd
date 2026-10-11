extends Node3D
## Independent world calibration; spatial fixtures never create a gameplay session.

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")
const RESOURCES = preload("res://src/bootstrap/world_resources.gd")

@export_file("*.json") var room_path := "res://content/world/newsroom_hd2d_calibration.json"
@export_enum("orthographic", "perspective") var camera_preset := "orthographic"
var room: Node3D


func _ready() -> void:
	var setup := STARTUP.prepare()
	var config := LOADER.read_dictionary(room_path)
	assert(setup.ok and config.ok, "HD-2D preview content must load")
	room = ROOM.instantiate()
	var prepared := RESOURCES.prepare(config.data, STARTUP.actor_textures(setup.data), setup.text)
	assert(prepared.ok, "HD-2D resources must validate before mount")
	room.configure(prepared.config, setup.data.actors.actors, prepared.textures)
	add_child(room)
	room.set_camera_preset(camera_preset)
