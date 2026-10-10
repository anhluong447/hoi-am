extends SceneTree
## Native renderer/input checks. Fixed simulation cadence is not a performance sample.

const PREVIEW = preload("res://src/bootstrap/previews/ui_preview.tscn")
const WORLD = preload("res://src/bootstrap/previews/world_preview.tscn")
const SUITE = preload("res://tests/test_suite.gd")

var _suite := SUITE.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var preview := PREVIEW.instantiate()
	root.add_child(preview)
	for dimensions: Vector2i in [Vector2i(1672, 941), Vector2i(1280, 720), Vector2i(1920, 1080)]:
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
		await process_frame
		press = press.duplicate()
		press.pressed = false
		root.push_input(press)
		await _settle()
		_suite.expect(choices == ["draft"], "Native pointer resolves same choice at " + str(dimensions))
		preview.view._buttons[0].grab_focus()
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		tab.pressed = true
		root.push_input(tab)
		await process_frame
		_suite.expect(preview.view._buttons[1].has_focus(), "Native Tab focus at " + str(dimensions))
		_suite.expect(preview.view._buttons[1].size == Vector2(413, 60), "Native plane hit target remains fixed")
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
	for failure: String in _suite.failures:
		push_error(failure)
	print("Native interaction: %d checks; %d failures" % [_suite.checks, _suite.failures.size()])
	quit(0 if _suite.failures.is_empty() else 1)


func _settle() -> void:
	for _frame: int in 5:
		await process_frame
	await RenderingServer.frame_post_draw
