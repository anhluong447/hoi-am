extends Node

signal back_requested

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")
const HUD = preload("res://src/presentation/coastal/hud_view.tscn")
const RESOURCES = preload("res://src/bootstrap/world_resources.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
## Isolated HD-2D preview: club now enters a side-scroll room, so name the pack.
const NEWSROOM_PATH := "res://content/world/newsroom_hd2d_v1.json"

var room: Node3D
var _hud: Control
var _text: RefCounted
var _config: Dictionary
var _target := ""
var _inspecting := false


func _ready() -> void:
	var setup := STARTUP.prepare()
	if not setup.ok:
		push_error(str(setup.error))
		get_tree().quit(1)
		return
	_text = setup.text
	_config = LOADER.read_dictionary(NEWSROOM_PATH).data
	room = ROOM.instantiate()
	var prepared := RESOURCES.prepare(_config, STARTUP.actor_textures(setup.data), setup.text)
	assert(prepared.ok, "World preview resources must validate")
	room.configure(prepared.config, setup.data.actors.actors, prepared.textures)
	room.interaction_requested.connect(_interact)
	room.nearby_changed.connect(func(id: String) -> void: _target = id)
	room.portal_requested.connect(_portal)
	room.menu_requested.connect(func() -> void: back_requested.emit())
	$World.add_child(room)
	_hud = HUD.instantiate()
	var model := STARTUP.fixture_model(setup.data.preview.hud, _text)
	_hud.configure(model, setup.data.hud_ui, STARTUP.ui_resources(setup.data))
	_hud.menu_requested.connect(func() -> void: back_requested.emit())
	$Interface.add_child(_hud)


func _process(_delta: float) -> void:
	if not room or not _hud or _inspecting:
		return
	var value := ""
	for definition: Dictionary in _config.targets:
		if definition.id == _target:
			value = _text.text("migration.world.prompt", {"target": _text.text(definition.label_key)})
	_hud.show_prompt(value, room.anchor_for(_target))


func _interact(id: String) -> void:
	_inspecting = true
	room.set_input_enabled(false)
	room.set_actor_talking(id, true)
	var anchor: Dictionary = room.anchor_for(id)
	_hud.show_prompt(_text.text("migration.world.inspected", {"target": _label(id)}), anchor)
	# Preview presentation only; no session/time progression is wired here.
	await get_tree().create_timer(0.7).timeout
	if not is_inside_tree():
		return
	room.set_actor_talking(id, false)
	room.set_input_enabled(true)
	_inspecting = false


func _portal(_room_id: String, _portal_id: String) -> void:
	room.player.position = room.safe_spawn(Vector3.INF)
	room.player.velocity = Vector3.ZERO


func _label(id: String) -> String:
	for definition: Dictionary in _config.targets:
		if definition.id == id:
			return _text.text(definition.label_key)
	return ""
