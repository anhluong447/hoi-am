extends SceneTree

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")

var _output := "res://artifacts/playable-review"
var _play: Node
var _count := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2 and args[0] == "--output":
		_output = args[1]
	if _output.begins_with("res://docs/"):
		assert(not DirAccess.dir_exists_absolute(_output), "Preserve historical review captures")
	DirAccess.make_dir_recursive_absolute(_output)
	_play = PLAY.instantiate()
	root.add_child(_play)
	# Club now mounts a side-scroll room (Task 8); this HD-2D evidence keeps the newsroom pack.
	_play._mount_room(preload("res://src/infrastructure/content/json_content_loader.gd").read_dictionary("res://content/world/newsroom_hd2d_v1.json").data)
	for _frame: int in 40:
		await physics_frame
	await _capture("room-high")
	_play.room.set_quality("low")
	await _capture("room-low")
	_play.room.set_quality("high")
	var environment: Environment = _play.room.get_node("WorldEnvironment").environment
	environment.fog_enabled = true
	environment.fog_density = 0.02
	await _capture("room-fog-ab")
	environment.fog_enabled = false
	environment.glow_enabled = true
	await _capture("room-glow-ab")
	environment.glow_enabled = false
	var attributes := CameraAttributesPractical.new()
	attributes.dof_blur_far_enabled = true
	attributes.dof_blur_far_distance = 20
	attributes.dof_blur_far_transition = 8
	_play.room.camera.attributes = attributes
	await _capture("room-dof-ab")
	_play.room.camera.attributes = null
	Input.action_press("move_left")
	for _frame: int in 35:
		await physics_frame
	Input.action_release("move_left")
	await _capture("walk")
	_play.interact("van")
	await _capture("dialogue-command")
	_play._advance("school")
	_play._advance()
	for section: String in ["calendar", "cases", "quests", "team", "editorial", "life", "travel", "reports", "saves"]:
		_play.controller.section = section
		_play.open_workspace()
		await _capture("workspace-" + section)
	_play.close_modal()
	_play.travel("library")
	await _capture("extension-library")
	_play._mount_room(preload("res://src/infrastructure/content/json_content_loader.gd").read_dictionary("res://content/world/newsroom_hd2d_v1.json").data)
	_play.room.set_camera_preset("perspective")
	await _capture("room-perspective")
	var file := FileAccess.open(_output.path_join("integrated-state.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(_play.setup.session.snapshot(), "  ", false, true))
	file.close()
	_play.queue_free()
	await process_frame
	_play = preload("res://src/bootstrap/gameplay/extension_preview.tscn").instantiate()
	root.add_child(_play)
	await _capture("extension-npc-room")
	_play.room.player.position = Vector3(2.7, 0.05, 0.2)
	for _frame: int in 20:
		await physics_frame
	await _capture("extension-npc-prompt")
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	Input.parse_input_event(interact)
	await process_frame
	assert(_play.controller.modal == "dialogue", "Authored NPC opens through actual world input")
	await _capture("extension-npc-dialogue")
	_play.queue_free()
	await process_frame
	_play = preload("res://src/bootstrap/sandbox/sandbox.tscn").instantiate()
	root.add_child(_play)
	await _capture("formula-tool")
	_play._command({"type": "benchmark", "id": "balanced"})
	while _play._busy:
		await process_frame
	await _capture("formula-benchmark")
	print("Playable captures: %d completed" % _count)
	quit()


func _capture(id: String) -> void:
	for _frame: int in 16:
		await process_frame
	await RenderingServer.frame_post_draw
	var status := root.get_texture().get_image().save_png(_output.path_join(id + ".png"))
	assert(status == OK, "Native capture failed")
	_count += 1
