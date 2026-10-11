extends "res://tests/test_suite.gd"

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const SESSION = preload("res://src/application/game_session.gd")
const GRAPH = preload("res://src/domain/dialogue/dialogue_graph.gd")


func run() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var play := PLAY.instantiate()
	tree.root.add_child(play)
	await tree.physics_frame
	await tree.physics_frame
	var initial: Dictionary = play.setup.session.snapshot()
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
	play._quality = "low"
	play.travel("library")
	await tree.physics_frame
	await tree.physics_frame
	expect(play.controller.location_id == "library" and play.setup.session.snapshot() == state, "Travel preserves pure progression")
	expect(not play.room.get_node("WindowSun").shadow_enabled, "Selected quality persists after room transition")
	expect(play.room.safe_spawn(Vector3(0, 999, 0)).y < 1, "Save positions above the room use safe authored spawn")
	play.room.portal_requested.emit("club", "library-to-club")
	expect(play.controller.location_id == "club", "Portal follows authored destination")
	play.travel("library")
	await tree.physics_frame
	play.controller.section = "life"
	var actions: Array = play.controller.workspace().rows
	expect(actions.any(func(row: Dictionary) -> bool: return row.get("command", {}).get("kind") == "hangout") and not actions.any(func(row: Dictionary) -> bool: return row.get("command", {}).get("kind") == "job"), "Personal actions follow source location contract")
	play.restore_world({"version": 1, "location_id": "unknown", "room_id": "missing", "position": [999, 0, 999]})
	await tree.physics_frame
	await tree.physics_frame
	expect(play.controller.location_id == "club" and play.room.player.position.length() < 10, "Unknown room uses authored safe spawn")
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
