extends SceneTree
## Reproducible native Forward+ captures, independent of source checkout.

const UI = preload("res://src/bootstrap/previews/ui_preview.tscn")
const WORLD = preload("res://src/bootstrap/previews/world_preview.tscn")


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	root.size = Vector2i(1672, 941)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var output := "res://artifacts/native-review/"
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() == 2 and arguments[0] == "--output":
		output = arguments[1].trim_suffix("/") + "/"
	if output.begins_with("res://docs/"):
		assert(not DirAccess.dir_exists_absolute(output), "Preserve historical capture directories; choose a new version")
	DirAccess.make_dir_recursive_absolute(output)
	var mask := Image.new()
	var mask_result := mask.load_svg_from_buffer(FileAccess.get_file_as_bytes("res://assets/ui/coastal/source/review/ui-mask.svg"))
	assert(mask_result == OK, "Cannot rasterize conservative review mask")
	mask.save_png(output + "ui-mask.png")
	var ui := UI.instantiate()
	root.add_child(ui)
	for background: String in ["neutral", "ui-light", "ui-dark", "ui-detail"]:
		ui.show_case("dialogue", background, true)
		await _settle()
		_save(output + "dialogue-" + background + ".png")
	ui.show_case("hud", "neutral", true)
	await _settle()
	_save(output + "hud-neutral.png")
	ui.show_case("hud", "ui-detail", true)
	await _settle()
	_save(output + "hud-detail.png")
	root.size = Vector2i(1280, 720)
	ui.show_case("dialogue", "ui-dark", true)
	await _settle()
	_save(output + "dialogue-1280x720.png")
	root.size = Vector2i(1920, 1080)
	await _settle()
	_save(output + "dialogue-1920x1080.png")
	ui.queue_free()
	await process_frame
	root.size = Vector2i(1672, 941)
	var world := WORLD.instantiate()
	root.add_child(world)
	await _settle()
	world.room.set_input_enabled(false)
	_save(output + "world-orthographic.png")
	world.room.set_camera_preset("perspective")
	await _settle()
	_save(output + "world-perspective.png")
	world.room.set_camera_preset("orthographic")
	for point: Dictionary in [{"id": "desk-front", "position": Vector3(-1, 0.05, 1)},
		{"id": "desk-behind", "position": Vector3(-1, 0.05, -1.8)},
		{"id": "window", "position": Vector3(1.5, 0.05, -3.9)},
		{"id": "door", "position": Vector3(0, 0.05, 3.8)}]:
		world.room.player.position = point.position
		world.room.player.velocity = Vector3.ZERO
		await _settle()
		_save(output + "world-" + point.id + ".png")
	world.room.player.position = Vector3(-1, 0.05, 1)
	for mode: String in ["sprite", "proxy", "contact"]:
		world.room.player.get_node("Rig").set_shadow_mode(mode)
		await _settle()
		_save(output + "shadow-" + mode + ".png")
	world.room.player.get_node("Rig").set_shadow_mode("proxy")
	for enabled: bool in [false, true]:
		world.room.player.get_node("Rig").set_billboard(enabled)
		await _settle()
		_save(output + ("billboard-y.png" if enabled else "billboard-fixed.png"))
	print("Native review: 19 captures saved; Forward+ device in engine log")
	world.queue_free()
	await process_frame
	quit()


func _settle() -> void:
	for _frame: int in 8:
		await process_frame
	await RenderingServer.frame_post_draw


func _save(path: String) -> void:
	var result := root.get_texture().get_image().save_png(path)
	assert(result == OK, "Cannot save native review capture")
