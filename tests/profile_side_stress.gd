extends SceneTree
## Native real-clock side-scroll stress profile. Never use fixed FPS, movie mode or headless.

const PREVIEW = preload("res://src/bootstrap/previews/side_stress_preview.tscn")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const SPEC_PATH := "res://content/world2d/stress/stress_v1.json"
var _options := {"--output": "", "--captures": "", "--warmup": "10", "--sample": "30",
	"--variants": "", "--resolutions": "1920x1080,2560x1440", "--screen": "largest"}
var _resolutions: Array[Vector2i] = []
var _variants: Array = []
var _report := {}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	for index in range(0, args.size() - 1, 2):
		assert(_options.has(args[index]), "Unknown option %s" % args[index])
		_options[args[index]] = args[index + 1]
	var output: String = _options["--output"]
	assert(output != "" and not FileAccess.file_exists(output), "Preserve profile samples")
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var spec: Dictionary = LOADER.read_dictionary(SPEC_PATH).data
	for text: String in _options["--resolutions"].split(","):
		_resolutions.append(Vector2i(int(text.get_slice("x", 0)), int(text.get_slice("x", 1))))
	var selected: PackedStringArray = _options["--variants"].split(",", false)
	_variants = spec.variants.filter(func(variant: Dictionary) -> bool: return selected.is_empty() or variant.id in selected)
	assert(selected.is_empty() or _variants.size() == selected.size(), "Unknown variant in --variants")
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 120
	OS.low_processor_usage_mode = false
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	var screen := _largest_screen() if _options["--screen"] == "largest" else int(_options["--screen"])
	DisplayServer.window_set_current_screen(screen)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	root.close_requested.connect(func() -> void: print("Side stress aborted: window close requested"))
	var rid := root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(rid, true)
	_report = {"engine": Engine.get_version_info(), "adapter": RenderingServer.get_video_adapter_name(),
		"adapter_vendor": RenderingServer.get_video_adapter_vendor(), "adapter_api_version": RenderingServer.get_video_adapter_api_version(),
		"api": RenderingServer.get_current_rendering_driver_name(), "renderer": RenderingServer.get_current_rendering_method(),
		"screen": {"index": screen, "size": _pair(DisplayServer.screen_get_size(screen)), "scale": DisplayServer.screen_get_scale(screen)},
		"vsync": "disabled", "cap_fps": 120, "fixed_fps": false, "warmup_seconds": float(_options["--warmup"]),
		"sample_seconds": float(_options["--sample"]), "spec_id": spec.id, "gpu_index_arg": _gpu_index(), "variants": _variants.map(func(v: Dictionary) -> String: return v.id), "light_settings": _light_settings(), "runs": [], "captures": {}}
	for resolution in _resolutions:
		DisplayServer.window_set_position(DisplayServer.screen_get_position(screen))
		DisplayServer.window_set_size(resolution)
		for frame in 10:
			await process_frame
		for variant: Dictionary in _variants:
			var preview := _mount(spec, variant)
			for frame in 5:
				await process_frame
			var run := await _measure(rid, preview)
			var discarded: Array = []
			# The desktop is shared during measurement; a minimised window renders nothing, so
			# restore it and repeat that variant instead of keeping invalid samples.
			while run.minimized_frames > 0 and discarded.size() < 3:
				discarded.append({"minimized_frames": run.minimized_frames, "frames": run.samples.size()})
				await _restore(screen, resolution)
				run = await _measure(rid, preview)
			run["discarded_attempts"] = discarded
			run.merge({"variant": variant.id, "resolution": [resolution.x, resolution.y], "hdr_2d": variant.hdr_2d,
				"glow": variant.glow, "plate_import": variant.plate_import, "light_grid": variant.light_grid,
				"plate_source": variant.get("plate_source", spec.plate_size), "runtime_lights": variant.get("runtime_lights", spec.lights.size()),
				"runtime_blur": variant.get("runtime_blur", true), "particles": variant.get("particles", "gpu"),
				"window_size": _pair(DisplayServer.window_get_size()), "window_mode": DisplayServer.window_get_mode(), "viewport_size": _pair(root.get_visible_rect().size)})
			if _options["--captures"] != "" and resolution.x == 1920:
				await _capture(preview, variant.id, 0.5, true)
				run["capture"] = variant.id
			_report.runs.append(run)
			_save(output)
			print("Side stress progress: %d/%d %s %dpx" % [_report.runs.size(), _resolutions.size() * _variants.size(), variant.id, resolution.x])
			preview.queue_free()
			for frame in 5:
				await process_frame
		# A borderless 1440p window fills the screen and cannot shrink back, so observe at 1080p first.
		if _options["--captures"] != "" and resolution == _resolutions[0]:
			await _observations(spec)
	_save(output)
	print("Side stress profile: %d runs; real clock; completed" % _report.runs.size())
	quit()


func _mount(spec: Dictionary, variant: Dictionary) -> Node:
	var preview := PREVIEW.instantiate()
	preview.configure(spec, variant)
	root.add_child(preview)
	root.grab_focus()
	return preview


func _restore(screen: int, resolution: Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_position(DisplayServer.screen_get_position(screen))
	DisplayServer.window_set_size(resolution)
	for frame in 10:
		await process_frame


func _measure(rid: RID, preview: Node) -> Dictionary:
	var minimized := 0
	var started := Time.get_ticks_usec()
	while Time.get_ticks_usec() - started < float(_options["--warmup"]) * 1000000.0:
		await process_frame
		minimized += int(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED)
	var samples: Array = []
	started = Time.get_ticks_usec()
	while Time.get_ticks_usec() - started < float(_options["--sample"]) * 1000000.0:
		var before := Time.get_ticks_usec()
		await process_frame
		minimized += int(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED)
		samples.append({"frame_ms": (Time.get_ticks_usec() - before) / 1000.0,
			"root_gpu_ms": RenderingServer.viewport_get_measured_render_time_gpu(rid),
			"render_cpu_ms": RenderingServer.get_frame_setup_time_cpu() + RenderingServer.viewport_get_measured_render_time_cpu(rid),
			"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
			"video_bytes": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),
			"texture_bytes": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)})
	return {"minimized_frames": minimized, "focused": root.has_focus(), "elapsed_seconds": (Time.get_ticks_usec() - started) / 1000000.0, "samples": samples}


## Freezes the camera, saves a half-size overview plus a native 512 px centre crop, and
## returns the full-resolution image for in-memory comparisons.
func _capture(preview: Node, name: String, phase: float, particles: bool) -> Dictionary:
	preview.freeze(phase, particles)
	for frame in 6:
		await process_frame
	var image := root.get_texture().get_image()
	var folder: String = _options["--captures"]
	var overview := image.duplicate()
	overview.resize(image.get_width() / 2, image.get_height() / 2, Image.INTERPOLATE_LANCZOS)
	var crop := image.get_region(Rect2i(image.get_size() / 2 - Vector2i(256, 256), Vector2i(512, 512)))
	for pair: Array in [[overview, "%s/%s.png" % [folder, name]], [crop, "%s/%s_crop.png" % [folder, name]]]:
		assert(not FileAccess.file_exists(pair[1]), "Preserve capture evidence")
		assert(pair[0].save_png(pair[1]) == OK)
	_report.captures[name] = {"image_size": _pair(image.get_size()), "phase_seconds": phase, "particles": particles}
	return {"name": name, "image": image}


func _observations(spec: Dictionary) -> void:
	assert(Vector2i(root.get_visible_rect().size) == _resolutions[0], "Observations run at the first resolution")
	var ids: Array = _variants.map(func(v: Dictionary) -> String: return v.id)
	_report.plate_compare = {}
	for pair: Array in spec.compare_pairs:
		if not (pair[0] in ids and pair[1] in ids):
			continue
		var images: Array[Image] = []
		for id: String in pair:
			var preview := _mount(spec, _variants[ids.find(id)])
			images.append((await _capture(preview, "compare_" + id, 0.5, false)).image)
			preview.queue_free()
			await process_frame
		_report.plate_compare["%s_vs_%s" % pair] = _difference(images[0], images[1])
	for capture: Dictionary in spec.captures:
		if not capture.base in ids:
			continue
		var variant: Dictionary = {}
		for candidate: Dictionary in _variants:
			if candidate.id == capture.base:
				variant = candidate.duplicate()
		variant.merge(capture, true)
		var preview := _mount(spec, variant)
		var image: Image = (await _capture(preview, capture.id, 0.0, false)).image
		var entry: Dictionary = _report.captures[capture.id]
		entry["settings"] = capture
		entry["actor_luminance"] = preview.actor_screen_rects().map(func(rect: Rect2) -> float: return _mean_luminance(image, rect))
		if capture.get("probe", false):
			var radius := int(spec.probe.sample_radius_px)
			var values: Array = preview.grid_screen_points().map(func(point: Vector2) -> float:
				return _mean_luminance(image, Rect2(point - Vector2.ONE * radius, Vector2.ONE * radius * 2)))
			entry["light_luminance"] = values
			entry["lights_total"] = values.size()
			entry["lights_lit"] = values.filter(func(value: float) -> bool: return value > float(spec.probe.lit_threshold)).size()
		preview.queue_free()
		await process_frame


func _difference(a: Image, b: Image) -> Dictionary:
	var squared := 0.0
	var count := 0
	for y in range(0, a.get_height(), 2):
		for x in range(0, a.get_width(), 2):
			var ca := a.get_pixel(x, y)
			var cb := b.get_pixel(x, y)
			for channel in 3:
				squared += pow(ca[channel] - cb[channel], 2.0)
				count += 1
	var mse := squared / count
	return {"mse": mse, "psnr_db": 10.0 * log(1.0 / max(mse, 1e-12)) / log(10.0), "stride_px": 2}


func _mean_luminance(image: Image, rect: Rect2) -> float:
	var area := Rect2i(rect).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var total := 0.0
	for y in range(area.position.y, area.end.y, 2):
		for x in range(area.position.x, area.end.x, 2):
			total += image.get_pixel(x, y).get_luminance()
	return total / max(1.0, ceil(area.size.x / 2.0) * ceil(area.size.y / 2.0))


func _gpu_index() -> int:
	var args := OS.get_cmdline_args()
	var at := args.find("--gpu-index")
	return int(args[at + 1]) if at >= 0 and at + 1 < args.size() else -1


func _largest_screen() -> int:
	var best := 0
	for index in DisplayServer.get_screen_count():
		var size := DisplayServer.screen_get_size(index)
		if size.x * size.y > DisplayServer.screen_get_size(best).x * DisplayServer.screen_get_size(best).y:
			best = index
	return best


func _light_settings() -> Dictionary:
	var settings := {}
	for property: Dictionary in ProjectSettings.get_property_list():
		var name: String = property.name
		if name.begins_with("rendering/") and "light" in name and ("2d" in name or "canvas" in name):
			settings[name] = ProjectSettings.get_setting(name)
	return settings


func _pair(value) -> Array:
	return [value.x, value.y]


func _save(output: String) -> void:
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string(JSON.stringify(_report))
	file.close()
