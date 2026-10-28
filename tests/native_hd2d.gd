extends SceneTree
## Native world integration, depth fixtures and legacy-position compatibility.

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
		assert(not DirAccess.dir_exists_absolute(_output), "Preserve HD-2D native evidence")
		DirAccess.make_dir_recursive_absolute(_output)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var play := PLAY.instantiate()
	root.add_child(play)
	await _frames(15)
	# Club now enters the side-scroll room3_2d; the newsroom HD-2D pack keeps its
	# art/depth coverage by mounting through the same composition helper.
	_suite.expect(play.room.has_method("safe_spawn_x") and play.controller.location_id == "club", "Playable club mounts the side-scroll room")
	play._mount_room(LOADER.read_dictionary("res://content/world/newsroom_hd2d_v1.json").data)
	await _frames(15)
	_suite.expect(play.room.has_node("Visuals") and play.room.get_node("Visuals").get_child_count() >= 40, "Playable mounts complete 2D-art newsroom")
	_suite.expect(play.room.get_node("Geometry").get_children().all(func(body: Node) -> bool: return not body.get_child(0).visible or body.get_child(0).cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY), "No solid blockout geometry renders in selected world")
	_suite.expect(play.room.get_node("Visuals/club-sign").text == play.setup.text.text("world.newsroom.sign"), "World sign resolves catalog copy")
	await _capture("01-playable")
	var original: Dictionary = play.setup.session.snapshot()
	play.room.player.set_physics_process(false)
	play.room.player.position = Vector3(-1, 0.05, -1.6)
	await _frames(4)
	await _capture("02-behind-desk")
	var behind := root.get_texture().get_image()
	play.room.player.position = Vector3(-1, 0.05, 1.0)
	await _frames(4)
	await _capture("03-before-desk")
	_suite.expect(behind.get_data() != root.get_texture().get_image().get_data(), "Native front/behind spatial fixtures render distinct depth cases")
	_suite.expect(play.setup.session.snapshot() == original, "World depth fixtures do not change gameplay state")
	play.room.player.position = Vector3(-1, 0.05, 1.6)
	for _frame: int in 60:
		play.room.player.velocity = Vector3(0, -0.3, -3)
		play.room.player.move_and_slide()
		await physics_frame
	_suite.expect(play.room.player.position.z >= 0.25, "Painted desk retains solid collision")
	# Legacy restores retarget to library, which remains an HD-2D location.
	play.restore_world({"version":1,"location_id":"library","room_id":"library","position":[0,0.05,2.5]})
	await _frames(12)
	_suite.expect(absf(play.room.player.position.z - 2.5) < 0.05, "Legacy room ID restores a valid position in selected pack")
	play.restore_world({"version":1,"location_id":"library","room_id":"library","position":[-1,0.05,-0.6]})
	await _frames(12)
	_suite.expect(play.room.player.position.distance_to(Vector3(0,0.05,2.9)) < 0.1, "Legacy position inside furniture falls back safely")
	play.interact("van")
	await _frames(30)
	play._modal.finish_reveal()
	await _frames(24)
	await _capture("04-dialogue")
	_suite.expect(not play.room._input_enabled and play.controller.modal == "dialogue", "Dialogue keeps new world input locked")
	play.close_modal()
	_suite.expect(not play.room._input_enabled, "World remains locked during dialogue reverse exit")
	await _frames(24)
	_suite.expect(play.room._input_enabled, "World unlocks after dialogue closes")
	play.travel("cafe")
	await _frames(10)
	play.travel("library")
	await _frames(10)
	_suite.expect(play.room.has_node("Visuals") and play.controller.location_id == "library", "Travel remounts injected world art without losing location ID")
	var motion: Node = play.room._motion
	play.room.player.set_physics_process(false)
	play.room.player.position.x += 2.0
	motion._process(1.0)
	_suite.expect(motion._offset.length() > 0.0 and absf(motion._offset.x) <= 0.25, "Camera follow is active and bounded")
	_suite.expect(motion._props.any(func(prop: Node3D) -> bool: return absf(prop.rotation.z) > 0.0), "Foliage uses independent authored idle phases")
	play.room.set_reduced_motion(true)
	_suite.expect(not motion.is_processing() and motion._offset == Vector3.ZERO, "Reduced motion disables camera follow")
	_suite.expect(motion._props.all(func(prop: Node3D) -> bool: return prop.rotation.z == 0.0), "Reduced motion restores foliage")
	_suite.expect(not play.room._atmosphere._dust.visible and play.room._atmosphere._water.material_override.get_shader_parameter("strength") == 0.0, "Reduced motion disables decorative particles and water displacement")
	play.room.set_quality("high")
	_suite.expect(not play.room._atmosphere._dust.visible, "Quality change preserves reduced motion")
	play.room.set_reduced_motion(false)
	_suite.expect(motion.is_processing() and play.room._atmosphere._dust.visible, "Full motion resumes after preference change")
	var phase: float = motion._phase
	var wave_time: float = play.room._atmosphere._elapsed
	paused = true
	await _frames(5)
	_suite.expect(motion._phase == phase and play.room._atmosphere._elapsed == wave_time, "Scene pause freezes foliage/camera and painted water clocks")
	_suite.expect(play.room._atmosphere._dust.speed_scale == 0.0, "Scene pause freezes GPU dust")
	paused = false
	_suite.expect(play.room._atmosphere._dust.speed_scale == 1.0, "Scene resume restores particle rate")
	var old_motion: WeakRef = weakref(motion)
	play.queue_free()
	await process_frame
	_suite.expect(old_motion.get_ref() == null, "Unmount releases local motion owner")
	for failure: String in _suite.failures:
		push_error(failure)
	print("Native HD-2D: %d checks; %d failures" % [_suite.checks, _suite.failures.size()])
	quit(0 if _suite.failures.is_empty() else 1)


func _frames(count: int) -> void:
	for _frame: int in count:
		await process_frame


func _capture(id: String) -> void:
	await RenderingServer.frame_post_draw
	if not _output.is_empty():
		assert(root.get_texture().get_image().save_png(_output.path_join(id + ".png")) == OK)
