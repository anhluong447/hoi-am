extends SceneTree
## Versioned native camera/art evidence; refuses to overwrite prior captures.

const PREVIEW = preload("res://src/bootstrap/previews/hd2d_preview.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() >= 2 and args[0] == "--output", "Expected versioned capture output")
	var output: String = args[1]
	assert(not DirAccess.dir_exists_absolute(output), "Preserve existing HD-2D evidence")
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280, 720)
	var preview := PREVIEW.instantiate()
	if args.size() == 4 and args[2] == "--room":
		preview.room_path = args[3]
	root.add_child(preview)
	for preset: String in ["orthographic", "perspective"]:
		preview.room.set_camera_preset(preset)
		for _frame: int in 15:
			await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(preset + ".png")) == OK)
	preview.queue_free()
	await process_frame
	print("HD-2D camera evidence: 2 captures; completed")
	quit()
