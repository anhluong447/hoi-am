extends SceneTree
## Real-clock UI profile; root render timings exclude separately measured child passes.

const PREVIEW = preload("res://src/bootstrap/previews/ui_preview.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 120
	OS.low_processor_usage_mode = false
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var output := "res://artifacts/profile/dialogue-motion.json"
	var args := OS.get_cmdline_user_args()
	var gpu_counters := not args.has("--no-gpu-counters")
	if args.size() >= 2 and args[0] == "--output":
		output = args[1]
		assert(not FileAccess.file_exists(output), "Preserve historical performance evidence")
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	var rows: Array = []
	var root_rid := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(root_rid, gpu_counters)
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = resolution
		root.grab_focus()
		for mode: String in ["empty", "static", "idle", "typewriter"]:
			preview.show_case("dialogue", "ui-dark", true)
			var view: Control = preview.view
			if mode == "empty":
				view.visible = false
			elif mode != "static":
				view.present(false)
				view.finish_reveal()
			var child_rid: RID = view._reading._viewport.get_viewport_rid()
			RenderingServer.viewport_set_measure_render_time(child_rid, gpu_counters)
			for _warmup: int in 60:
				await process_frame
			var samples: Array = []
			for index: int in 240:
				var start := Time.get_ticks_usec()
				if mode == "typewriter" and not view._reading.revealing:
					view._reading.start(false)
				await process_frame
				samples.append({"frame_ms": (Time.get_ticks_usec() - start) / 1000.0,
					"root_gpu_ms": RenderingServer.viewport_get_measured_render_time_gpu(root_rid) if gpu_counters else null,
					"text_gpu_ms": RenderingServer.viewport_get_measured_render_time_gpu(child_rid) if gpu_counters else null,
					"process_ms": Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
					"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
					"video_memory_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),
					"text_viewport_active": view._reading._viewport.render_target_update_mode == SubViewport.UPDATE_ALWAYS})
			rows.append({"mode": mode, "resolution": [resolution.x, resolution.y], "window_focused": root.has_focus(), "samples": samples})
	var report := {"engine": Engine.get_version_info(), "adapter": RenderingServer.get_video_adapter_name(),
		"api": RenderingServer.get_current_rendering_driver_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"vsync": "disabled", "max_fps": 120, "fixed_fps": false, "gpu_counters": gpu_counters,
		"warmup_frames": 60, "samples_per_run": 240, "runs": rows}
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  ", false, true))
	file.close()
	print("Dialogue motion profile: 8 runs; 1920 measured frames; real clock; completed")
	quit()
