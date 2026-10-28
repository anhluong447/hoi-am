extends SceneTree
## All selected locations: approach, live anchors, commands, saves and preserved art.

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const SUITE = preload("res://tests/test_suite.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
var _suite := SUITE.new()
var _output := ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--output":
		_output = args[1]
		assert(not DirAccess.dir_exists_absolute(_output), "Preserve room review captures")
		DirAccess.make_dir_recursive_absolute(_output)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var play := PLAY.instantiate()
	root.add_child(play)
	var state: Dictionary = play.setup.session.snapshot()
	var locations: Dictionary = LOADER.read_dictionary("res://content/world/locations.json").data.locations
	# club/school/home moved to side-scroll rooms (Task 8); HD-2D coverage stays on the rest.
	for id: String in ["library", "cafe", "shop", "job", "waterfront"]:
		assert(not locations[id].has("kind"), "Only HD-2D locations run this suite")
		play.travel(id)
		await _frames(15)
		var room: Node3D = play.room
		_suite.expect(room.has_node("Visuals") and room._config.id == locations[id].room_id, id + ": selected painted pack mounts")
		_suite.expect(room.get_node("Geometry").get_children().all(func(body: Node) -> bool: return not body.get_child(0).visible or body.get_child(0).cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY), id + ": no visible blockout boxes")
		var spawn := Vector3(room._config.spawn[0], room._config.spawn[1], room._config.spawn[2])
		_suite.expect(room.safe_spawn(spawn).distance_to(spawn) < .01, id + ": authored spawn is collision-free")
		await _capture(id + "-high")
		room.set_quality("low")
		await _frames(8)
		await _capture(id + "-low")
		room.set_quality("high")
		room.player.set_physics_process(false)
		if id in ["waterfront", "job"]:
			for side: int in [-1, 1]:
				room.player.position = room.safe_spawn(Vector3(side * 7.6, .05, 3.0))
				room._motion._process(1.0)
				await _frames(10)
				_suite.expect(absf(room._motion._offset.x) <= .35 and absf(room._motion._offset.z) <= .22, id + ": camera remains bounded at edge")
				await _capture(id + "-edge-" + str(side))
		for target: Dictionary in room._config.targets:
			var candidate := Vector3(target.position[0], .05, target.position[2] + .65)
			room.player.position = room.safe_spawn(candidate)
			await _frames(8)
			_suite.expect(room.player.position.distance_to(candidate) < .1, id + ": approach space " + target.id)
			_suite.expect(room.anchor_for(target.id).get("visible", false), id + ": readable target anchor " + target.id)
			_suite.expect(room._nearby == target.id, id + ": nearest interact target " + target.id)
			var event := InputEventAction.new()
			event.action = "interact"
			event.pressed = true
			room._unhandled_input(event)
			await _frames(30)
			_suite.expect(not play.controller.modal.is_empty() and not room._input_enabled, id + ": target opens modal " + target.id)
			play.close_modal()
			await _frames(30)
		_suite.expect(play.setup.session.snapshot() == state, id + ": world/UI review leaves progression unchanged")
		play.restore_world({"version":1,"location_id":id,"room_id":id,"position":[0,.05,2.5]})
		await _frames(8)
		room = play.room
		_suite.expect(room.player.position.distance_to(Vector3(0,.05,2.5)) < .1, id + ": legacy room ID restores valid position")
		var old: WeakRef = weakref(room)
		var destination: String = room._config.portal.to
		room.player.position = Vector3(0, .05, room._config.portal.position[2] - .8)
		room.player.set_physics_process(true)
		Input.action_press("move_down")
		for step: int in 60:
			await physics_frame
			if play.controller.location_id == destination:
				break
		Input.action_release("move_down")
		await _frames(5)
		_suite.expect(play.controller.location_id == destination, id + ": walking through portal changes room")
		_suite.expect(old.get_ref() == null, id + ": travel frees old scene/resources")
	play.queue_free()
	await process_frame
	for failure: String in _suite.failures:
		push_error(failure)
	print("Native HD-2D locations: %d checks; %d failures" % [_suite.checks, _suite.failures.size()])
	quit(0 if _suite.failures.is_empty() else 1)


func _frames(count: int) -> void:
	for _frame: int in count:
		await process_frame


func _capture(id: String) -> void:
	await RenderingServer.frame_post_draw
	if not _output.is_empty():
		assert(root.get_texture().get_image().save_png(_output.path_join(id + ".png")) == OK)
