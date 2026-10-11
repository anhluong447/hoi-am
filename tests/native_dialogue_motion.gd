extends SceneTree
## Real Forward+ render/input checks and optional versioned motion evidence.

const PREVIEW = preload("res://src/bootstrap/previews/ui_preview.tscn")
const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const SUITE = preload("res://tests/test_suite.gd")

var _suite := SUITE.new()
var _output := ""
var _captures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	root.size = Vector2i(1280, 720)
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--output":
		_output = args[1]
		assert(not DirAccess.dir_exists_absolute(_output), "Preserve historical motion evidence")
		DirAccess.make_dir_recursive_absolute(_output)
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	preview.show_case("dialogue", "ui-dark", true)
	var view: Control = preview.view
	view.present(false)
	await _capture("01-open-start")
	await _frames(6)
	await _capture("02-wave-paper")
	await _frames(8)
	await _capture("03-decorations")
	await _frames(16)
	await _capture("04-ink-front")
	_suite.expect(view._reading.revealing and view._reading._surface.visible and view._reading._surface.material.get_shader_parameter("radius") > 0.0, "Native typewriter uses a shader-blurred glyph tail")
	var early := root.get_texture().get_image()
	_suite.expect(_ink_pixels(early, Rect2i(233, 765, 1020, 110)) > 10, "Native glyph passes draw visible partial ink")
	await _frames(40)
	await _capture("05-typewriter")
	var later := root.get_texture().get_image()
	_suite.expect(_ink_pixels(later, Rect2i(233, 765, 1020, 110)) > _ink_pixels(early, Rect2i(233, 765, 1020, 110)), "Native typewriter progressively draws more paragraph ink")
	await _click(Vector2(1100, 820))
	_suite.expect(not view._reading.revealing and view._labels.line.visible and view._state == "choices", "Pointer click completes text without choosing")
	await _frames(22)
	await _capture("06-choices")
	var button: Button = view._buttons[1]
	var bounds := button.get_rect()
	_move(button.get_rect().get_center())
	await _frames(12)
	await _capture("07-hover-draft")
	_suite.expect(view._choices._rows[1].scale.x > 1.03 and button.get_rect() == bounds, "Native hover enlarges artwork while hit target stays fixed")
	_move(Vector2(1100, 700))
	await _frames(12)
	view._buttons[2].grab_focus()
	await _frames(12)
	await _capture("08-keyboard-focus")
	_suite.expect(view._choices._rows[2].scale.x > 1.03 and view._choices._rows[1].scale == Vector2.ONE, "Native keyboard focus shares hover motion and restores siblings")
	# Exercise blur-disabled A/B at the same text clock, without altering any art.
	view.present(false)
	await _frames(37)
	view._reading.set_process(false)
	view._motion.set_process(false)
	await _capture("09-blur-on")
	var blur_on := root.get_texture().get_image()
	view._reading._surface.material.set_shader_parameter("radius", 0.0)
	await _frames(2)
	await _capture("10-blur-off-ab")
	_suite.expect(blur_on.get_data() != root.get_texture().get_image().get_data(), "Native blur A/B changes rendered pixels at a frozen text clock")
	view._reading._surface.material.set_shader_parameter("radius", view._layout.motion.typewriter.blur_radius)
	view._motion.set_process(true)
	view.finish_reveal()
	await _frames(22)
	view._choices.close_rows()
	await _frames(5)
	_suite.expect(view._choices._rows[2].modulate.a < view._choices._rows[0].modulate.a, "Choice exit reverses entrance stagger")
	view._choices.reveal(false)
	await _frames(22)
	var new_line: Dictionary = view._model.duplicate(true)
	new_line.choices = []
	new_line.line = preview._setup.text.text("play.objective")
	var paper: int = view._layers.paper.get_instance_id()
	view.transition(new_line)
	await _frames(12)
	await _capture("11-next-line")
	_suite.expect(view._layers.paper.get_instance_id() == paper and view._layers.paper.position == Vector2.ZERO, "Native line change retains the paper in place")
	await _key(KEY_ENTER)
	_suite.expect(view._labels.line.visible and not view._reading.revealing, "Enter completes current sentence before advance")
	await _frames(5)
	await _capture("12-idle-a")
	var wave_phase: float = view._motion._wave.get_shader_parameter("phase")
	await _frames(90)
	await _capture("13-idle-b")
	_suite.expect(view._motion._wave.get_shader_parameter("phase") > wave_phase and view._layers.paper.position == Vector2.ZERO, "Native idle moves wave phase while reading surface stays fixed")
	view.dismiss()
	await _frames(8)
	await _capture("14-close-content")
	await _frames(7)
	await _capture("15-close-paper")
	await _frames(10)
	await _capture("16-closed")
	preview.queue_free()
	await process_frame
	await _integrated()
	for failure: String in _suite.failures:
		push_error(failure)
	print("Native dialogue motion: %d checks; %d failures; %d captures" % [_suite.checks, _suite.failures.size(), _captures])
	quit(0 if _suite.failures.is_empty() else 1)


func _integrated() -> void:
	var play := PLAY.instantiate()
	root.add_child(play)
	await _frames(20)
	play.interact("van")
	var view: Control = play._modal
	var before: Dictionary = play.setup.session.snapshot()
	await _frames(30)
	await _key(KEY_ENTER)
	_suite.expect(play.setup.session.snapshot() == before and view._labels.line.visible, "First native Enter reveals text without executing gameplay")
	await _frames(22)
	await _capture("17-playable-dialogue")
	await _key(KEY_ENTER)
	_suite.expect(play.setup.session.snapshot().phase == "club" and play._modal == view, "Second native Enter executes focused stable-ID choice and retains dialogue view")
	await _frames(12)
	await _key(KEY_ENTER)
	await _frames(2)
	await _capture("18-playable-next-line")
	_suite.expect(play._modal == view and play.controller.modal == "dialogue" and not play.room._input_enabled, "Sentence reveal keeps world input locked")
	await _key(KEY_ENTER)
	_suite.expect(view.is_closing() and not play.room._input_enabled and play.controller.modal == "dialogue", "Closing retains modal priority through exit animation")
	await _key(KEY_ENTER)
	await _key(KEY_ESCAPE)
	await _frames(24)
	_suite.expect(play.room._input_enabled and play.controller.modal.is_empty() and play._modal == null, "Repeated input during exit releases world exactly once")
	play._reduced = true
	play.interact("van")
	await _capture("19-reduced-motion")
	_suite.expect(play._modal._state == "ready" and not play._modal._motion.is_processing(), "Native reduced motion displays settled UI without idle clock")
	play.close_modal()
	_suite.expect(play._modal == null and play.room._input_enabled, "Native reduced motion closes immediately")
	play.interact("van")
	play._reduced = false
	play._modal.present(false)
	play.close_modal()
	play.open_workspace()
	await _frames(30)
	_suite.expect(play.controller.modal == "workspace" and play._modal != null and not play.room._input_enabled, "Replacing an exiting conversation cannot run a stale unlock callback")
	play.queue_free()
	await process_frame


func _capture(id: String) -> void:
	await RenderingServer.frame_post_draw
	if not _output.is_empty():
		assert(root.get_texture().get_image().save_png(_output.path_join(id + ".png")) == OK, "Native motion screenshot")
		_captures += 1


func _frames(count: int) -> void:
	for _frame: int in count:
		await process_frame


func _move(point: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = root.get_final_transform() * point
	event.global_position = event.position
	root.push_input(event)


func _click(point: Vector2) -> void:
	_move(point)
	var event := InputEventMouseButton.new()
	event.position = root.get_final_transform() * point
	event.global_position = event.position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	await process_frame
	event.pressed = false
	root.push_input(event)


func _ink_pixels(bitmap: Image, area: Rect2i) -> int:
	var count := 0
	area = Rect2i(root.get_final_transform() * Rect2(area)).intersection(Rect2i(Vector2i.ZERO, bitmap.get_size()))
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			var pixel := bitmap.get_pixel(x, y)
			if pixel.r < 0.3 and pixel.g < 0.3 and pixel.b < 0.4:
				count += 1
	return count
