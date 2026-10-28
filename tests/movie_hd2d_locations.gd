extends SceneTree
## Forty-six-second final native tour; movie cadence is visual evidence only.

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var play := PLAY.instantiate()
	root.add_child(play)
	var state: Dictionary = play.setup.session.snapshot()
	# club/school/home are side-scroll rooms since Task 8; this movie covers HD-2D locations.
	for id: String in ["library", "cafe", "shop", "job", "waterfront"]:
		play.travel(id)
		for frame: int in 300:
			if frame == 60:
				Input.action_press("move_right")
			if frame == 120:
				Input.action_release("move_right")
			if frame == 150:
				Input.action_press("move_left")
			if frame == 210:
				Input.action_release("move_left")
			await process_frame
	play.travel("club")
	play.interact("van")
	for frame: int in 300:
		if frame == 120:
			play._modal.finish_reveal()
		await process_frame
	play.close_modal()
	for frame: int in 60:
		await process_frame
	assert(play.setup.session.snapshot() == state, "World tour must preserve progression")
	play.queue_free()
	await process_frame
	print("HD-2D world tour: 2760 review frames; completed")
	quit()
