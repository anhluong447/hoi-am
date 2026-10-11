extends Node

signal back_requested
@export var reading_room_extension := false

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const CONTROLLER = preload("res://src/presentation/controllers/play_controller.gd")
const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")
const HUD = preload("res://src/presentation/coastal/hud_view.tscn")
const DIALOGUE = preload("res://src/presentation/coastal/dialogue_view.tscn")
const WORKSPACE = preload("res://src/presentation/workspace/workspace_view.tscn")
const SAVE_DIALOGS = preload("res://src/bootstrap/gameplay/save_dialogs.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const CONFIRM = preload("res://src/bootstrap/gameplay/personal_confirmation.gd")

var setup: Dictionary
var controller: RefCounted
var room: Node3D
var _hud: Control
var _modal: Control
var _saves: Node
var _resources: Dictionary
var _nearby := ""
var _reduced := false
var _quality := "high"
var _room_id := "newsroom"


func _ready() -> void:
	setup = STARTUP.prepare(reading_room_extension)
	assert(setup.ok, "Playable content must validate")
	_resources = STARTUP.ui_resources(setup.data)
	controller = CONTROLLER.new(setup.session, setup.text, setup.data)
	var locations := LOADER.read_dictionary("res://content/world/locations.json")
	var entry: Dictionary = locations.data.locations.club
	_room_id = entry.room_id
	_mount_room(LOADER.read_dictionary(entry.room_path).data)
	if reading_room_extension:
		controller.location_id = "library"
		_room_id = "reading_room_extension"
		_mount_room(LOADER.read_dictionary("res://content/extensions/reading_room/room.json").data)
	_hud = HUD.instantiate()
	_hud.configure(controller.hud(), setup.data.hud_ui, _resources)
	_hud.menu_requested.connect(open_workspace)
	_hud.map_requested.connect(func() -> void:
		controller.section = "travel"
		open_workspace())
	$Interface.add_child(_hud)
	_saves = SAVE_DIALOGS.new()
	_saves.configure(setup, world_snapshot)
	_saves.loaded.connect(restore_world)
	_saves.status_changed.connect(func(value: String) -> void:
		controller.message = value
		open_workspace())
	add_child(_saves)


func _mount_room(config: Dictionary) -> void:
	if is_instance_valid(room):
		$World.remove_child(room)
		room.queue_free()
	room = ROOM.instantiate()
	room.configure(config, setup.data.actors.actors, STARTUP.actor_textures(setup.data))
	room.interaction_requested.connect(interact)
	room.nearby_changed.connect(func(id: String) -> void: _nearby = id)
	room.portal_requested.connect(func(destination: String, _portal: String) -> void: travel(destination))
	room.menu_requested.connect(open_workspace)
	$World.add_child(room)
	room.set_quality(_quality)
	room.set_input_enabled(controller.modal.is_empty())
	_nearby = ""


func _process(_delta: float) -> void:
	if not room or not _hud:
		return
	if not controller.modal.is_empty():
		_hud.show_prompt("", {"visible": false})
		return
	_hud.show_prompt(controller.prompt(room.target_label_key(_nearby)), room.anchor_for(_nearby))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and not controller.modal.is_empty():
		close_modal()
		get_viewport().set_input_as_handled()


func interact(id: String) -> void:
	if not controller.modal.is_empty():
		return
	if id == "library-visitor" and reading_room_extension:
		controller.begin_dialogue(id)
		_show_dialogue()
	elif id == "van":
		controller.begin_dialogue("club_welcome" if setup.session.snapshot().phase == "morning" else "van")
		_show_dialogue()
	else:
		controller.section = {"writing-desk": "quests", "assignment-board": "cases", "archive": "reports", "printer": "editorial", "club-clock": "calendar"}.get(id, "calendar")
		open_workspace()


func open_workspace() -> void:
	_clear_modal()
	_hud.visible = true
	controller.modal = "workspace"
	room.set_input_enabled(false)
	_modal = WORKSPACE.instantiate()
	_modal.configure(controller.workspace(), setup.data.workspace, _resources["Source Serif 4"])
	_modal.command_requested.connect(_intent)
	_modal.section_requested.connect(func(id: String) -> void:
		controller.section = id
		open_workspace())
	_modal.close_requested.connect(close_modal)
	$Interface.add_child(_modal)
	_modal.present(_reduced)
	_refresh()


func _intent(command: Dictionary) -> void:
	match command.get("intent", ""):
		"travel":
			travel(command.id)
		"talk":
			if controller.begin_dialogue(command.id):
				_show_dialogue()
		"save", "load", "import":
			_saves.request(command)
		"quit":
			back_requested.emit()
		"motion":
			_reduced = not _reduced
			controller.option("reduced_motion", _reduced)
			open_workspace()
		"quality":
			_quality = "low" if _quality == "high" else "high"
			controller.option("quality", _quality)
			room.set_quality(_quality)
			open_workspace()
		_:
			if command.get("type") == "date":
				CONFIRM.open(self, controller, setup.text, command)
				return
			var result: Dictionary = controller.execute(command)
			var state: Dictionary = setup.session.snapshot()
			if result.ok and state.phase == "bed" and state.messages.any(func(m: Dictionary) -> bool: return not m.resolved):
				controller.section = "editorial"
			open_workspace()


func _show_dialogue() -> void:
	_clear_modal()
	room.set_input_enabled(false)
	room.set_actor_talking("van", true)
	_modal = DIALOGUE.instantiate()
	_modal.configure(controller.dialogue(), setup.data.dialogue_ui, _resources)
	_modal.choice_requested.connect(_advance)
	_modal.continue_requested.connect(func() -> void: _advance())
	$Interface.add_child(_modal)
	_hud.visible = false
	_modal.present(_reduced)


func _advance(id: String = "") -> void:
	if not is_instance_valid(_modal) or _modal.is_closing():
		return
	if controller.advance(id):
		_modal.transition(controller.dialogue())
	else:
		close_modal()


func close_modal() -> void:
	if is_instance_valid(_modal) and _modal.has_method("dismiss"):
		if _modal.is_closing():
			return
		controller.modal = "dialogue"
		var exiting := _modal
		exiting.closed.connect(func() -> void:
			if _modal == exiting:
				_finish_close(), CONNECT_ONE_SHOT)
		exiting.dismiss()
		return
	_finish_close()


func _finish_close() -> void:
	_clear_modal()
	controller.modal = ""
	_hud.visible = true
	room.set_actor_talking("van", false)
	room.set_input_enabled(true)
	get_viewport().gui_release_focus()
	_refresh()


func _clear_modal() -> void:
	if is_instance_valid(_modal):
		_modal.get_parent().remove_child(_modal)
		_modal.queue_free()
	_modal = null


func _refresh() -> void:
	_hud.render(controller.hud())


func travel(id: String) -> void:
	var loaded := LOADER.read_dictionary("res://content/world/locations.json")
	if not loaded.ok or not loaded.data.locations.has(id):
		id = "club"
	var definition: Dictionary = loaded.data.locations[id]
	var config := LOADER.read_dictionary(definition.room_path)
	_room_id = definition.room_id
	controller.location_id = id
	_mount_room(config.data)
	close_modal()


func world_snapshot() -> Dictionary:
	var p: Vector3 = room.player.position
	return {"version": 1, "location_id": controller.location_id, "room_id": _room_id, "position": [p.x, p.y, p.z]}


func restore_world(world: Dictionary) -> void:
	travel(world.location_id)
	room.set_input_enabled(false)
	await get_tree().physics_frame
	if not is_inside_tree():
		return
	var position: Array = world.get("position", [INF, INF, INF]) if world.room_id == _room_id else [INF, INF, INF]
	room.player.position = room.safe_spawn(Vector3(position[0], position[1], position[2]))
	room.player.velocity = Vector3.ZERO
	room.set_input_enabled(controller.modal.is_empty())
	_refresh()
