extends SceneTree
## Real elapsed-time world profile; never use fixed FPS or movie mode here.

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
var _play: Node


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() in [2, 4] and args[0] == "--output")
	var regression := args.size() == 4 and args[2] == "--rooms"
	var room_ids := args[3].split(",") if regression else PackedStringArray(["club"])
	var expected_count := room_ids.size() * 6 if regression else 42
	var output: String = args[1]
	assert(not FileAccess.file_exists(output), "Preserve profile samples")
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 120
	OS.low_processor_usage_mode = false
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	_play = PLAY.instantiate()
	root.add_child(_play)
	var rid := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	var report := {"engine": Engine.get_version_info(), "adapter": RenderingServer.get_video_adapter_name(),
		"api": RenderingServer.get_current_rendering_driver_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"driver": "See machine.json (Windows adapter driver)", "vsync": "disabled", "cap_fps": 120,
		"fixed_fps": false, "warmup_seconds": 10, "sample_seconds": 30, "repetitions": 3, "locations": room_ids,
		"note": "Editor remains open. Root GPU counter excludes dialogue child viewport; wall frame time includes all passes.", "runs": []}
	var resolutions: Array[Vector2i] = [Vector2i(1280,720),Vector2i(1920,1080)]
	if regression:
		resolutions = [Vector2i(1920,1080)]
	for location: String in room_ids:
		_play.travel(location)
		for resolution: Vector2i in resolutions:
			root.size = resolution
			root.grab_focus()
			var cases: Array[String] = ["static-high", "static-low", "walk-high", "walk-low", "dialogue-high", "dialogue-low"]
			if regression:
				cases = ["walk-high", "walk-low"]
			elif resolution.x == 1920:
				cases.append_array(["hidden", "effects-off"])
			for mode: String in cases:
				for repetition: int in 3:
					_prepare(mode)
					var started := Time.get_ticks_usec()
					while Time.get_ticks_usec() - started < 10000000:
						_drive(mode, (Time.get_ticks_usec() - started) / 1000000.0)
						await process_frame
					var samples: Array = []
					started = Time.get_ticks_usec()
					while Time.get_ticks_usec() - started < 30000000:
						var before := Time.get_ticks_usec()
						_drive(mode, (before - started) / 1000000.0)
						await process_frame
						samples.append({"frame_ms": (Time.get_ticks_usec() - before) / 1000.0,
							"root_gpu_ms": RenderingServer.viewport_get_measured_render_time_gpu(rid),
							"render_cpu_ms": RenderingServer.get_frame_setup_time_cpu() + RenderingServer.viewport_get_measured_render_time_cpu(rid),
							"process_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
							"physics_ms": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
							"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
							"objects": Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
							"static_bytes": Performance.get_monitor(Performance.MEMORY_STATIC),
							"video_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)})
					report.runs.append({"location": _play.controller.location_id, "room_id": _play.room._config.id, "camera": _play.room._config.camera.orthographic, "resolution": [resolution.x, resolution.y], "mode": mode, "repetition": repetition + 1,
						"focused": root.has_focus(), "elapsed_seconds": (Time.get_ticks_usec() - started) / 1000000.0, "samples": samples})
					var file := FileAccess.open(output, FileAccess.WRITE)
					file.store_string(JSON.stringify(report))
					file.close()
					print("HD-2D profile progress: %d/%d %s %dpx" % [report.runs.size(), expected_count, mode, resolution.x])
	Input.action_release("move_left")
	Input.action_release("move_right")
	print("HD-2D profile: %d runs; real clock; completed" % expected_count)
	quit()


func _prepare(mode: String) -> void:
	_play._finish_close()
	_play.room.visible = mode != "hidden"
	_play._hud.visible = mode != "hidden"
	_play.room.set_quality("low" if mode.ends_with("low") else "high")
	_play.room.set_reduced_motion(mode == "effects-off")
	if mode == "effects-off":
		_play.room.set_quality("low")
	var spawn: Array = _play.room._config.spawn
	_play.room.player.position = Vector3(spawn[0],spawn[1],spawn[2])
	Input.action_release("move_left")
	Input.action_release("move_right")
	if mode.begins_with("dialogue"):
		_play.interact("van")


func _drive(mode: String, seconds: float) -> void:
	if mode.begins_with("walk"):
		var right := int(seconds / 1.2) % 2 == 0
		Input.action_press("move_right" if right else "move_left")
		Input.action_release("move_left" if right else "move_right")
	elif mode.begins_with("dialogue") and is_instance_valid(_play._modal):
		if not _play._modal._reading.revealing:
			_play._modal._reading.start(false)
