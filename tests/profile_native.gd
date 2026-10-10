extends SceneTree

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 120
	root.size = Vector2i(1280, 720)
	var started := Time.get_ticks_usec()
	var play := PLAY.instantiate()
	root.add_child(play)
	await process_frame
	var load_ms := (Time.get_ticks_usec() - started) / 1000.0
	var rid := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	var rows: Array = []
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = resolution
		for quality: String in ["high", "low", "dof-off", "dust-off", "water-off", "fog", "glow"]:
			play.room.set_quality("low" if quality == "low" else "high")
			var environment: Environment = play.room.get_node("WorldEnvironment").environment
			environment.fog_enabled = quality == "fog"
			environment.fog_density = 0.02
			environment.glow_enabled = quality == "glow"
			if quality == "dof-off":
				play.room.camera.attributes.dof_blur_far_enabled = false
			if quality == "dust-off":
				play.room._atmosphere._dust.emitting = false
				play.room._atmosphere._dust.visible = false
			if quality == "water-off":
				play.room._atmosphere._water.material_override.set_shader_parameter("strength", 0.0)
			for _warmup: int in 120:
				await process_frame
			var samples: Array = []
			for index: int in 300:
				var start := Time.get_ticks_usec()
				if index == 30:
					Input.action_press("move_right")
				if index == 80:
					Input.action_release("move_right")
				if index == 120:
					play.controller.section = "cases"
					play.open_workspace()
				if index == 180:
					play.close_modal()
				await process_frame
				samples.append({"frame_ms": (Time.get_ticks_usec() - start) / 1000.0,
					"render_cpu_ms": RenderingServer.get_frame_setup_time_cpu() + RenderingServer.viewport_get_measured_render_time_cpu(rid),
					"gpu_ms": RenderingServer.viewport_get_measured_render_time_gpu(rid),
					"process_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
					"physics_ms": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
					"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
					"static_memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC),
					"video_memory_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)})
			rows.append({"quality": quality, "resolution": [resolution.x, resolution.y], "samples": samples})
	var report := {"engine": Engine.get_version_info(), "adapter": RenderingServer.get_video_adapter_name(),
		"api": RenderingServer.get_current_rendering_driver_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"vsync": "disabled", "max_fps": 120, "fixed_fps": false, "scene_ready_ms": load_ms, "runs": rows}
	DirAccess.make_dir_recursive_absolute("res://artifacts/profile")
	var file := FileAccess.open("res://artifacts/profile/native.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  ", false, true))
	file.close()
	print("Native profile: 14 runs; 4200 measured frames; real clock; completed")
	quit()
