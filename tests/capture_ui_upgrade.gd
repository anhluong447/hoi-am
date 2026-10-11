extends SceneTree
## UI-only background/ratio/copy review, followed by a real integrated playable.

const PREVIEW = preload("res://src/bootstrap/previews/ui_preview.tscn")
const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const PROBE = preload("res://tests/coastal_render_probe.gd")

var _output := "res://artifacts/ui-upgrade"
var _count := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.size = Vector2i(1672, 941)
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--output":
		_output = args[1]
	assert(not DirAccess.dir_exists_absolute(_output), "Choose a new review version")
	DirAccess.make_dir_recursive_absolute(_output)
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	for screen: String in ["dialogue", "hud"]:
		for background: String in ["neutral", "ui-light", "ui-dark", "ui-detail"]:
			preview.show_case(screen, background, true)
			await _capture(screen + "-" + background)
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(2560, 1080)]:
		root.size = dimensions
		for screen: String in ["dialogue", "hud"]:
			preview.show_case(screen, "ui-dark", true)
			await _capture(screen + "-" + str(dimensions.x) + "x" + str(dimensions.y))
	root.size = Vector2i(1672, 941)
	preview.show_case("dialogue", "neutral", true)
	preview.view._buttons[1].grab_focus()
	await _capture("dialogue-selected-draft")
	preview.view._buttons[0].grab_focus()
	await _capture("dialogue-selection-return")
	preview.show_case("dialogue", "ui-dark", true)
	var model: Dictionary = preview.view._model.duplicate(true)
	model.choices[0].text = preview._setup.text.text("ui.review.long_choice")
	model.line += "\n" + model.line
	preview.view.configure(model, preview.view._layout, preview.view._resources)
	await _capture("dialogue-long-copy")
	preview.show_case("hud", "ui-light", true)
	model = preview.view._model.duplicate(true)
	model.money = preview._setup.text.text("ui.hud.money", {"money": {"number": 1000000000, "format": "vi_integer"}})
	preview.view.render(model)
	preview.view.show_prompt(preview._setup.text.text("migration.world.prompt", {"target": preview._setup.text.text("extension.visitor")}), {"visible": true, "position": Vector2(2, 2)})
	await _capture("hud-large-values-edge-prompt")
	preview.queue_free()
	await process_frame
	root.size = Vector2i(1280, 720)
	var play := PLAY.instantiate()
	root.add_child(play)
	for _frame: int in 20:
		await physics_frame
	await _capture("playable-morning")
	play.interact("van")
	await _capture("playable-dialogue")
	play._advance("school")
	play._advance()
	await _capture("playable-club")
	play.controller.section = "travel"
	play.open_workspace()
	await _capture("playable-locations")
	print("UI upgrade capture: %d screenshots completed" % _count)
	quit()


func _capture(id: String) -> void:
	for _frame: int in 16:
		await process_frame
	await RenderingServer.frame_post_draw
	var bitmap := root.get_texture().get_image()
	assert(bitmap.save_png(_output.path_join(id + ".png")) == OK, "Native PNG capture")
	if id.begins_with("dialogue-") and bitmap.get_size() == Vector2i(1672, 941):
		var preview: Node = root.get_child(root.get_child_count() - 1)
		if not PROBE.choices_visible(bitmap, preview.view):
			push_error("Missing dialogue glyph/icon in capture: " + id)
			quit(1)
			return
	_count += 1
