extends SceneTree
## Forty-second deterministic review clip. Movie cadence is not a benchmark.

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var play := PLAY.instantiate()
	root.add_child(play)
	# Club now mounts a side-scroll room (Task 8); this HD-2D evidence keeps the newsroom pack.
	play._mount_room(preload("res://src/infrastructure/content/json_content_loader.gd").read_dictionary("res://content/world/newsroom_hd2d_v1.json").data)
	for frame: int in 2400:
		if frame == 240:
			Input.action_press("move_left")
		if frame == 330:
			Input.action_release("move_left")
			Input.action_press("move_up")
		if frame == 440:
			Input.action_release("move_up")
		if frame == 580:
			Input.action_press("move_right")
		if frame == 760:
			Input.action_release("move_right")
		if frame == 900:
			play.interact("van")
		if frame == 1170:
			play._modal.finish_reveal()
		if frame == 1390:
			play.close_modal()
		if frame == 1560:
			play.room.set_reduced_motion(true)
		if frame == 1800:
			play.room.set_reduced_motion(false)
		if frame == 1950:
			play.room.set_quality("low")
		if frame == 2190:
			play.room.set_quality("high")
		await process_frame
	play.queue_free()
	await process_frame
	print("HD-2D motion movie: 2400 review frames; completed")
	quit()
