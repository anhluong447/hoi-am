extends SceneTree
## Native renderer/input checks. Fixed simulation cadence is not a performance sample.

const PREVIEW = preload("res://src/bootstrap/previews/ui_preview.tscn")
const WORLD = preload("res://src/bootstrap/previews/world_preview.tscn")
const SUITE = preload("res://tests/test_suite.gd")
const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const PROBE = preload("res://tests/coastal_render_probe.gd")

var _suite := SUITE.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	root.size = Vector2i(1672, 941)
	for background: String in ["neutral", "ui-light", "ui-dark", "ui-detail"]:
		preview.show_case("dialogue", background, true)
		await _settle()
		_suite.expect(PROBE.choices_visible(root.get_texture().get_image(), preview.view), "Native initial selected/idle glyphs and all icons: " + background)
	for dimensions: Vector2i in [Vector2i(1672, 941), Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(1024, 768), Vector2i(2560, 1080)]:
		root.size = dimensions
		preview.show_case("dialogue", "ui-dark", true)
		await _settle()
		var choices: Array = []
		preview.view.choice_requested.connect(func(id: String) -> void: choices.append(id))
		var button: Button = preview.view._buttons[1]
		var point: Vector2 = button.get_global_transform_with_canvas() * (button.size / 2.0)
		point = root.get_final_transform() * point
		var motion := InputEventMouseMotion.new()
		motion.position = point
		motion.global_position = point
		root.push_input(motion)
		var press := InputEventMouseButton.new()
		press.position = point
		press.global_position = point
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		root.push_input(press)
		# Pair synthetic press/release in one input batch; OS events between frames
		# must not cancel the fixture's pressed button at large window sizes.
		press = press.duplicate()
		press.pressed = false
		root.push_input(press)
		await _settle()
		_suite.expect(choices == ["draft"], "Native pointer resolves same choice at " + str(dimensions) + "; received=" + str(choices) + "; point=" + str(point) + "; viewport=" + str(root.get_visible_rect()))
		_suite.expect(preview.view._buttons[1].has_focus() and preview.view._choice_mark[1].visible, "Native pointer selection preserves rebuilt focus at " + str(dimensions))
		preview.view._buttons[0].grab_focus()
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		tab.pressed = true
		root.push_input(tab)
		await process_frame
		_suite.expect(preview.view._buttons[1].has_focus(), "Native Tab focus at " + str(dimensions))
		_suite.expect(preview.view._buttons[1].size == Vector2(413, 60), "Native plane hit target remains fixed")
		preview.show_case("hud", "ui-light", true)
		await _settle()
		var mapped: Array = []
		var returned: Array = []
		preview.view.map_requested.connect(func() -> void: mapped.append(true))
		preview.back_requested.connect(func() -> void: returned.append(true), CONNECT_ONE_SHOT)
		await _click(preview.view._map)
		_suite.expect(mapped.size() == 1, "HUD map pointer through letterbox at " + str(dimensions))
		await _click(preview.view._menu)
		_suite.expect(returned.size() == 1, "HUD menu pointer through letterbox at " + str(dimensions))
		var map_key := InputEventKey.new()
		map_key.physical_keycode = KEY_M
		map_key.keycode = KEY_M
		map_key.pressed = true
		root.push_input(map_key)
		await _settle()
		_suite.expect(mapped.size() == 2, "Native M action emits local map request")
		map_key.pressed = false
		root.push_input(map_key)
		preview.view._map.grab_focus()
		root.push_input(tab)
		await _settle()
		_suite.expect(preview.view._menu.has_focus(), "HUD Tab follows map then menu")
		var accepted: Array = []
		preview.back_requested.connect(func() -> void: accepted.append(true), CONNECT_ONE_SHOT)
		var accept_key := InputEventKey.new()
		accept_key.keycode = KEY_ENTER
		accept_key.pressed = true
		root.push_input(accept_key)
		await process_frame
		accept_key.pressed = false
		root.push_input(accept_key)
		await _settle()
		_suite.expect(accepted.size() == 1, "HUD Enter activates focused menu")
		if dimensions == Vector2i(1672, 941):
			preview.show_case("dialogue", "ui-dark", true)
			var model: Dictionary = preview.view._model.duplicate(true)
			model.choices[0].text = preview._setup.text.text("ui.review.long_choice")
			preview.view.configure(model, preview.view._layout, preview.view._resources)
			await _settle()
			var bitmap := root.get_texture().get_image()
			_suite.expect(_ink_pixels(bitmap, Rect2i(559, 471, 310, 45), true) > 100, "Native selected teal glyphs remain drawn after reconfigure")
			_suite.expect(_ink_pixels(bitmap, Rect2i(511, 478, 28, 28), true) > 30, "Native choice icon remains drawn after font resources change")
			_suite.expect(_ink_pixels(bitmap, Rect2i(559, 543, 310, 40), false) > 100 and _ink_pixels(bitmap, Rect2i(559, 609, 310, 40), false) > 100 and _ink_pixels(bitmap, Rect2i(511, 546, 28, 28), true) > 30, "Native idle glyphs and icon remain drawn alongside selected weight")
			preview.view._buttons[1].grab_focus()
			await _settle()
			bitmap = root.get_texture().get_image()
			_suite.expect(_ink_pixels(bitmap, Rect2i(559, 543, 310, 40), true) > 100 and _ink_pixels(bitmap, Rect2i(511, 546, 28, 28), true) > 30, "Native selected glyphs and icon survive keyboard weight change")
	preview.queue_free()
	await process_frame
	root.size = Vector2i(1672, 941)
	var world := WORLD.instantiate()
	root.add_child(world)
	await _settle()
	var before: Vector3 = world.room.player.position
	Input.action_press("move_right")
	for _frame: int in 24:
		await physics_frame
	Input.action_release("move_right")
	_suite.expect(world.room.player.position.distance_to(before) > 0.5, "Native Forward+ walk")
	_suite.expect(world.room.player.get_node("Rig/Sprite").animation == "walk_right", "Camera-relative native facing")
	world.room.set_input_enabled(false)
	before = world.room.player.position
	Input.action_press("move_up")
	for _frame: int in 12:
		await physics_frame
	Input.action_release("move_up")
	_suite.expect(Vector2(before.x - world.room.player.position.x, before.z - world.room.player.position.z).length() < 0.001, "Native world input lock")
	world.queue_free()
	await process_frame
	await _playable_checks()
	for failure: String in _suite.failures:
		push_error(failure)
	print("Native interaction: %d checks; %d failures" % [_suite.checks, _suite.failures.size()])
	quit(0 if _suite.failures.is_empty() else 1)


func _playable_checks() -> void:
	var play := PLAY.instantiate()
	root.add_child(play)
	await _settle()
	for dimensions: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = dimensions
		play.open_workspace()
		await _settle()
		var panel: PanelContainer = play._modal.get_child(1)
		var tabs: HBoxContainer = panel.get_child(0).get_child(1)
		var target: Button = tabs.get_child(1)
		var point: Vector2 = root.get_final_transform() * (target.get_global_transform_with_canvas() * (target.size / 2.0))
		var press := InputEventMouseButton.new()
		press.position = point
		press.global_position = point
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		root.push_input(press)
		press = press.duplicate()
		press.pressed = false
		root.push_input(press)
		await _settle()
		_suite.expect(play.controller.section == "cases", "Native workspace tab pointer at " + str(dimensions))
		_suite.expect(not play.room._input_enabled, "Native modal movement lock")
		var cancel := InputEventJoypadButton.new()
		cancel.button_index = JOY_BUTTON_START
		cancel.pressed = true
		root.push_input(cancel)
		await _settle()
		_suite.expect(play.controller.modal.is_empty() and play.room._input_enabled, "Gamepad menu restores world input")
		var map_key := InputEventKey.new()
		map_key.physical_keycode = KEY_M
		map_key.pressed = true
		root.push_input(map_key)
		await _settle()
		_suite.expect(play.controller.section == "travel" and play.controller.modal == "workspace" and not play.room._input_enabled, "M opens actual location workspace and locks movement")
		play.close_modal()
		map_key.pressed = false
		root.push_input(map_key)
		cancel = cancel.duplicate()
		cancel.pressed = false
		root.push_input(cancel)
	play.queue_free()
	await process_frame


func _settle() -> void:
	for _frame: int in 5:
		await process_frame
	await RenderingServer.frame_post_draw


func _click(button: Button) -> void:
	var point: Vector2 = root.get_final_transform() * (button.get_global_transform_with_canvas() * (button.size / 2.0))
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await _settle()


func _ink_pixels(bitmap: Image, region: Rect2i, teal: bool) -> int:
	var count := 0
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			var pixel := bitmap.get_pixel(x, y)
			if pixel.r < 0.3 and ((pixel.g > 0.3 and pixel.b > 0.3) if teal else (pixel.g < 0.3 and pixel.b < 0.4)):
				count += 1
	return count
