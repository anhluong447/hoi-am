extends "res://tests/test_suite.gd"

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const SESSION = preload("res://src/application/game_session.gd")
const GRAPH = preload("res://src/domain/dialogue/dialogue_graph.gd")
const CONTRACT = preload("res://src/domain/gameplay/save_contract.gd")


func run() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var play := PLAY.instantiate()
	tree.root.add_child(play)
	await tree.physics_frame
	await tree.physics_frame
	var initial: Dictionary = play.setup.session.snapshot()
	expect(play.room.has_method("safe_spawn_x") and play.room._config.id == "room3_2d" and play.controller.location_id == "club", "Playable starts in the side-scroll club room")
	expect(play.room._light_phase == "sang", "Side room starts on the session phase light")
	var graph: Dictionary = play.setup.data.playable_dialogue.scenes.club_welcome.duplicate(true)
	graph.nodes.start.choices.reverse()
	expect(GRAPH.choices(graph.nodes.start, initial)[1].id == "school", "Authored choice identity survives reordered layout")
	graph.nodes.start.choices[0].id = "school"
	expect(not GRAPH.validate(graph, play.setup.data.catalog), "Duplicate authored choice identity rejected")
	graph.nodes.start.choices[0].erase("id")
	graph.nodes.start.choices[1].id = "0"
	expect(not GRAPH.validate(graph, play.setup.data.catalog), "Explicit identity cannot collide with legacy positional identity")
	play.interact("van")
	expect(play.controller.modal == "dialogue" and not play.room._input_enabled, "NPC dialogue owns modal priority")
	play._advance("school")
	expect(play.setup.session.snapshot().phase == "club" and play.setup.session.snapshot().energy == 4, "Explicit dialogue choice executes real school command")
	play._advance()
	for _frame: int in 24:
		await tree.process_frame
	expect(play.controller.modal.is_empty() and play.room._input_enabled, "End dialogue restores world input")
	expect(play.room._light_phase == "chieu", "Refresh maps the new session phase onto side-room lighting")
	var replay := SESSION.new(play.setup.rules.transition, play.setup.validator.validate)
	replay.replace(initial)
	replay.execute({"type": "school"})
	expect(replay.snapshot() == play.setup.session.snapshot(), "Integrated command matches headless replay")
	var state: Dictionary = play.setup.session.snapshot()
	play.interact("van")
	play._advance()
	play.close_modal()
	expect(play.setup.session.snapshot() == state, "Conversation-only advances no gameplay time or energy")
	for _repeat: int in 8:
		play.open_workspace()
		play.close_modal()
		await tree.process_frame
	expect(play.get_node("Interface").get_child_count() == 1, "Repeated modal disposal retains only HUD")
	play.open_workspace()
	play._intent({"type": "sleep"})
	expect(play.setup.session.snapshot() == state and not play.controller.message.is_empty(), "Rejected UI command shows catalog feedback and preserves session")
	for section: String in ["cases", "quests", "team", "editorial", "life", "travel", "reports", "saves"]:
		play.controller.section = section
		play.open_workspace()
		expect(not play.controller.workspace().rows.is_empty(), "Real management model " + section)
	play.close_modal()
	await _side_doors(tree, play, state)
	play._quality = "low"
	play.travel("library")
	await tree.physics_frame
	await tree.physics_frame
	expect(play.controller.location_id == "library" and play.setup.session.snapshot() == state, "Travel preserves pure progression")
	expect(not play.room.get_node("WindowSun").shadow_enabled, "Selected quality persists after room transition")
	expect(play.room.safe_spawn(Vector3(0, 999, 0)).y < 1, "Save positions above the room use safe authored spawn")
	play.room.portal_requested.emit("club", "library-to-club")
	await tree.physics_frame
	await tree.physics_frame
	expect(play.controller.location_id == "club", "Portal follows authored destination")
	play.travel("library")
	await tree.physics_frame
	play.controller.section = "life"
	var actions: Array = play.controller.workspace().rows
	expect(actions.any(func(row: Dictionary) -> bool: return row.get("command", {}).get("kind") == "hangout") and not actions.any(func(row: Dictionary) -> bool: return row.get("command", {}).get("kind") == "job"), "Personal actions follow source location contract")
	play.restore_world({"version": 1, "location_id": "unknown", "room_id": "missing", "position": [999, 0, 999]})
	await tree.physics_frame
	await tree.physics_frame
	expect(play.controller.location_id == "club" and play.room._config.id == "room3_2d" and is_equal_approx(play.room.player.position.x, 1600.0), "Unknown room uses the club entry room travel spawn")
	var world: Dictionary = play.world_snapshot()
	expect(world == {"version": 2, "location_id": "club", "room_id": "room3_2d", "x": 1600.0, "facing": 1} and CONTRACT.valid_world(world), "Side-room snapshot writes the v2 x/facing shape")
	play.restore_world({"version": 1, "location_id": "school", "room_id": "corridor_c_2d"})
	await tree.physics_frame
	expect(play.controller.location_id == "school" and play.room._config.id == "school_gate_2d" and play.room._input_enabled, "v1 side-room restore enters the location entry room")
	play.queue_free()
	await tree.process_frame
	await tree.process_frame
	var extension := preload("res://src/bootstrap/gameplay/extension_preview.tscn").instantiate()
	tree.root.add_child(extension)
	await tree.physics_frame
	await tree.physics_frame
	expect(not extension.room.target_label_key("library-visitor").is_empty(), "Extension prompt comes from mounted room targets")
	extension.interact("library-visitor")
	expect(extension.controller.modal == "dialogue", "Authored extension NPC/graph mounts without core rule changes")
	extension.close_modal()
	extension.controller.execute({"type": "school"})
	var result: Dictionary = extension.controller.execute({"type": "open", "id": "W1-library-ledger"})
	expect(result.ok and extension.setup.validator.validate(extension.setup.session.snapshot()).ok, "New authored case uses existing command and schema")
	extension.queue_free()
	await tree.process_frame


func _side_doors(tree: SceneTree, play: Node, state: Dictionary) -> void:
	play.room.place_player("travel", 3100.0)
	await tree.physics_frame
	await tree.physics_frame
	expect(play.room._nearby == "to_corridor", "Player stands at the corridor door")
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	play.room._unhandled_input(event)
	expect(not play.room._input_enabled, "Door request locks the mounted room")
	await tree.process_frame
	await tree.physics_frame
	expect(play.room._config.id == "corridor_c_2d" and play.controller.location_id == "school", "Cross-location door enters the authored target room")
	expect(is_equal_approx(play.room.player.position.x, 4500.0), "Door honours the authored target spawn")
	await _walk_door(tree, play, 4600.0)
	expect(play.room._config.id == "room3_2d" and play.controller.location_id == "club" and is_equal_approx(play.room.player.position.x, 3000.0), "Corridor door returns to room3_2d in club")
	await _walk_door(tree, play, 3100.0)
	expect(play.room._config.id == "corridor_c_2d" and play.controller.location_id == "school", "Room3 door re-enters the corridor")
	expect(play.setup.session.snapshot() == state, "Walking through doors costs no gameplay time")
	var old: WeakRef = weakref(play.room)
	play.room.door_requested.emit("class_11a3_2d", "from_corridor")
	play.room.door_requested.emit("canteen_2d", "from_corridor")
	await tree.process_frame
	await tree.process_frame
	expect(play.room._config.id == "class_11a3_2d" and play.get_node("World").get_child_count() == 1, "Two door requests in one frame mount exactly one room")
	expect(old.get_ref() == null, "Door transition frees the previous room")
	expect(play.room._input_enabled, "Mounted room input reopens after the door transition")
	play.interact("van")
	expect(not play.room._input_enabled, "Dialogue locks side-room input")
	play.close_modal()
	for _frame: int in 24:
		await tree.process_frame
	expect(play.room._input_enabled, "Closing dialogue reopens side-room input")


func _walk_door(tree: SceneTree, play: Node, x: float) -> void:
	play.room.place_player("travel", x)
	await tree.physics_frame
	await tree.physics_frame
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	play.room._unhandled_input(event)
	await tree.process_frame
	await tree.physics_frame
