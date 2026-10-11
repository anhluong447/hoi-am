extends SceneTree
## Isolate lighting and camera effects at the same framing, with preserved captures.

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 2 and args[0] == "--output")
	var output: String = args[1]
	assert(not DirAccess.dir_exists_absolute(output), "Preserve quality A/B evidence")
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var play := PLAY.instantiate()
	root.add_child(play)
	var sun: DirectionalLight3D = play.room.get_node("WindowSun")
	var energy := sun.light_energy
	var count := 0
	for mode: String in ["high", "low", "dof-off", "dust-off", "shadow-off", "sun-off", "fog", "glow"]:
		play.room.set_quality("low" if mode == "low" else "high")
		sun.light_energy = 0.0 if mode == "sun-off" else energy
		var environment: Environment = play.room.get_node("WorldEnvironment").environment
		environment.fog_enabled = mode == "fog"
		environment.fog_density = 0.015
		environment.glow_enabled = mode == "glow"
		if mode == "dof-off":
			play.room.camera.attributes.dof_blur_far_enabled = false
			play.room.camera.attributes.dof_blur_near_enabled = false
		if mode == "dust-off":
			play.room._atmosphere._dust.emitting = false
			play.room._atmosphere._dust.visible = false
		if mode == "shadow-off":
			sun.shadow_enabled = false
		for _frame: int in 12:
			await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(mode + ".png")) == OK)
		count += 1
	play.queue_free()
	await process_frame
	print("HD-2D quality evidence: %d captures; completed" % count)
	quit()
