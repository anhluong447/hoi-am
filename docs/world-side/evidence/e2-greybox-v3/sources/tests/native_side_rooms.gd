extends SceneTree
## Native functional walkthrough. Wall-clock samples are observations, not a GPU benchmark.

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const SUITE = preload("res://tests/test_suite.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const SAVES = preload("res://src/application/gameplay_saves.gd")
const STORE = preload("res://src/infrastructure/saves/file_save_store.gd")
const PHASES := {"sang": "morning", "chieu": "investigation", "toi": "evening", "dem": "bed"}
const ROUTE := ["corridor_c_2d", "school_gate_2d", "discipline_office_2d", "school_gate_2d", "corridor_c_2d", "class_11a3_2d", "corridor_c_2d", "canteen_2d", "corridor_c_2d", "room3_2d"]

var _suite := SUITE.new()
var _output := ""
var _rooms: Array[Dictionary] = []
var _transitions: Array[Dictionary] = []
var _captures := 0


func _initialize() -> void:
	# Keep OS input out of the long fixture; synthetic viewport actions still run.
	root.set_flag(Window.FLAG_NO_FOCUS, true)
	root.set_flag(Window.FLAG_MOUSE_PASSTHROUGH, true)
	_run.call_deferred()


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Side-room native walkthrough requires a window and GPU")
		quit(1)
		return
	var args := OS.get_cmdline_user_args()
	if args.size() == 2 and args[0] == "--output":
		_output = args[1]
	elif not args.is_empty():
		push_error("Expected --output <new directory>")
		quit(1)
		return
	if _output.is_empty():
		_output = "res://artifacts/native-side-rooms/run-%d" % Time.get_unix_time_from_system()
	if DirAccess.dir_exists_absolute(_output) or DirAccess.make_dir_recursive_absolute(_output) != OK:
		push_error("Evidence output must be a new writable directory: " + _output)
		quit(1)
		return
	Engine.max_fps = 60
	root.size = Vector2i(1920, 1080)
	root.content_scale_size = Vector2i(1672, 941)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	var play := PLAY.instantiate()
	root.add_child(play)
	await _frames(12)
	var initial: Dictionary = play.setup.session.snapshot()
	await _inspect(play)
	if _suite.failures.is_empty():
		await _dialogue_lock(play)
	for destination: String in ROUTE:
		if not _suite.failures.is_empty():
			break
		await _door(play, destination)
		if _suite.failures.is_empty() and not _rooms.any(func(row: Dictionary) -> bool: return row.id == destination):
			await _inspect(play)
	if _suite.failures.is_empty():
		play.travel("home")
		await _frames(12)
		await _inspect(play)
		_suite.expect(_rooms.size() == 7, "All seven side rooms visited")
		_suite.expect(_captures == 28, "Four lighting captures per room")
		_suite.expect(play.setup.session.snapshot() == initial, "Walking, doors, lighting and dialogue reveal preserve progression")
		await _save_restore(play)
	play.queue_free()
	await _frames(3)
	var report := {
		"schema_version": 1, "created_at_utc": Time.get_datetime_string_from_system(true),
		"engine": Engine.get_version_info().string, "os": OS.get_name(), "os_version": OS.get_version(),
		"cpu": OS.get_processor_name(), "gpu": RenderingServer.get_video_adapter_name(),
		"renderer": RenderingServer.get_current_rendering_method(), "driver": RenderingServer.get_current_rendering_driver_name(),
		"window": [root.size.x, root.size.y], "max_fps": Engine.max_fps, "physics_ticks_per_second": Engine.physics_ticks_per_second,
		"viewport_texture": [root.get_texture().get_width(), root.get_texture().get_height()],
		"capture_method": "Unscaled native viewport pixels centered on a black window-sized canvas, restoring the KEEP letterbox; no content resizing.",
		"checks": _suite.checks, "failures": _suite.failures, "captures": _captures,
		"rooms": _rooms, "transitions": _transitions,
		"scope": "Synthetic Godot input; greybox functional evidence. Ten-second wall-clock frame samples at cap 60 are informational; no iGPU, GPU budget or art acceptance claim.",
	}
	var file := FileAccess.open(_output.path_join("report.json"), FileAccess.WRITE)
	if file == null:
		_suite.expect(false, "Report writable")
	else:
		file.store_string(JSON.stringify(report, "  ") + "\n")
		file.close()
	for failure: String in _suite.failures:
		push_error(failure)
	print("Native side rooms: %d checks; %d failures; %d captures; output=%s" % [_suite.checks, _suite.failures.size(), _captures, _output])
	quit(0 if _suite.failures.is_empty() else 1)


func _inspect(play: Node) -> void:
	var room: Node = play.room
	var id: String = room._config.id
	if _rooms.any(func(row: Dictionary) -> bool: return row.id == id):
		_suite.expect(false, "Refuse to overwrite captures for an already visited room: " + id)
		return
	_suite.expect(room.has_method("safe_spawn_x") and room._input_enabled, id + ": side room mounted and input enabled")
	_suite.expect(_inside(room), id + ": authored spawn inside bounds")
	_suite.expect(play._hud._labels.location.text == play.controller.hud().location, id + ": displayed HUD location matches current world location")
	var targets: Array = room._config.interactions if not room._config.interactions.is_empty() else room._config.doors
	var target: Dictionary = targets[0]
	await _walk_to(room, float(target.x))
	await _frames(12)
	_suite.expect(room._nearby == target.id, id + ": walking reaches authored target")
	_suite.expect(play._hud._prompt.is_visible_in_tree() and not play._hud._prompt.text.is_empty(), id + ": live HUD prompt visible")
	_suite.expect(play._hud._prompt.text == play.controller.prompt(room.target_label_key(target.id)), id + ": prompt uses target catalog copy")
	for phase: String in PHASES:
		room.set_reduced_motion(true)
		room.set_lighting_phase(PHASES[phase])
		room.set_reduced_motion(false)
		await _frames(4)
		_suite.expect(room.lighting._canvas.color.is_equal_approx(Color.html(room._config.lighting.phases[phase].modulate)), id + ": lighting " + phase)
		await RenderingServer.frame_post_draw
		var image := _window_image()
		_suite.expect(image.get_size() == Vector2i(1920, 1080), id + ": native capture dimensions " + phase)
		var saved := image.save_png(_output.path_join(id + "-" + phase + ".png"))
		_suite.expect(saved == OK, id + ": captured " + phase)
		if saved == OK:
			_captures += 1
	room.set_lighting_phase(play.setup.session.snapshot().phase)
	await _frames(100)
	var sample: Dictionary = await _sample_walk(room)
	_rooms.append({"id": id, "location_id": play.controller.location_id, "prompt_target": target.id, "walk_sample": sample})
	print("Side-room visited: " + id)


## KEEP omits the two black side columns from the viewport texture at 1080p.
## Rebuild only that letterbox; retain every rendered content pixel unchanged.
func _window_image() -> Image:
	var source := root.get_texture().get_image()
	source.convert(Image.FORMAT_RGBA8)
	var size := source.get_size()
	_suite.expect(size.x <= root.size.x and size.y <= root.size.y, "Native viewport fits the window without resizing")
	var image := Image.create(root.size.x, root.size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	image.blit_rect(source, Rect2i(Vector2i.ZERO, size), (root.size - size) / 2)
	return image


func _door(play: Node, destination: String) -> void:
	var room: Node = play.room
	var source: String = room._config.id
	var door: Dictionary = {}
	for candidate: Dictionary in room._config.doors:
		if candidate.get("target_room") == destination:
			door = candidate
	_suite.expect(not door.is_empty(), source + ": door to " + destination)
	if door.is_empty():
		return
	await _walk_to(room, float(door.x))
	await _frames(6)
	_suite.expect(room._nearby == door.id, source + ": door reached through movement input")
	var old: WeakRef = weakref(room)
	await _tap("interact")
	await _frames(8)
	_suite.expect(play.room._config.id == destination, source + ": interaction enters " + destination)
	if play.room._config.id != destination:
		return
	_suite.expect(old.get_ref() == null and play.get_node("World").get_child_count() == 1, source + ": previous room freed exactly once")
	var target: Dictionary = LOADER.read_dictionary("res://content/world2d/rooms/" + destination + ".json").data
	_suite.expect(play.controller.location_id == target.location_id, destination + ": location derived from destination content")
	_suite.expect(is_equal_approx(play.room.player.position.x, float(target.spawns[door.target_spawn].x)), destination + ": authored destination spawn")
	_suite.expect(_inside(play.room) and play.room._input_enabled, destination + ": safe spawn and unlocked input")
	_transitions.append({"from": source, "to": destination, "spawn": door.target_spawn})


func _dialogue_lock(play: Node) -> void:
	await _walk_to(play.room, 1800.0)
	_suite.expect(play.room._nearby == "van", "Dialogue probe approaches Van through movement input")
	await _tap("interact")
	await _frames(30)
	_suite.expect(play.controller.modal == "dialogue" and not play.room._input_enabled, "Van dialogue locks world input")
	if play.controller.modal != "dialogue":
		print("Dialogue probe opened unexpected modal: ", play.controller.modal, "; nearby=", play._nearby, "; x=", play.room.player.position.x)
		return
	var view: Control = play._modal
	var room: Node = play.room
	var x: float = room.player.position.x
	Input.action_press("move_right")
	await _frames(12)
	Input.action_release("move_right")
	_suite.expect(is_equal_approx(room.player.position.x, x), "Dialogue blocks held walking input")
	var state: Dictionary = play.setup.session.snapshot()
	await _tap("ui_accept")
	_suite.expect(play._modal == view and play.setup.session.snapshot() == state and view._labels.line.visible, "First reveal input shows text and dispatches no choice")
	if play._modal != view:
		return
	play.close_modal()
	_suite.expect(not room._input_enabled, "Dialogue exit retains world lock")
	await _tap("interact")
	await _frames(90)
	_suite.expect(play.room == room and room._input_enabled and play.controller.modal.is_empty(), "Exit unlocks once without a stray interaction")


func _save_restore(play: Node) -> void:
	var setup: Dictionary = play.setup
	var store := STORE.new(_output.path_join("saves"))
	var service := SAVES.new(setup.session, setup.data.gameplay, store.read_slot, store.write_slot, setup.validator.validate, setup.data.locations.legacy_maps)
	play.travel("school")
	play.enter_room("corridor_c_2d", "from_gate")
	await _frames(8)
	await _walk_to(play.room, 1234.0)
	play.room.player.face(-1)
	var world: Dictionary = play.world_snapshot()
	_suite.expect(service.save("slot_1", world, "native-side-e2").ok, "Native v2 save writes through real store")
	play.travel("library")
	await _frames(8)
	var loaded: Dictionary = service.load_slot("slot_1")
	_suite.expect(loaded.ok, "Native v2 save loads")
	await play.restore_world(loaded.world)
	await _frames(8)
	_suite.expect(play.world_snapshot() == world and play.room._input_enabled, "Native v2 restores exact room/x/facing")
	var legacy: Dictionary = LOADER.read_dictionary("res://content/world/locations.json").data
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/saves/world_v1_club_3d.json"))
	loaded = service.import_payload(fixture)
	_suite.expect(loaded.ok and legacy.locations.club.kind == "side", "Native v1 HD-2D save imports at converted location")
	var state: Dictionary = setup.session.snapshot()
	await play.restore_world(loaded.world)
	await _frames(8)
	_suite.expect(play.room._config.id == "room3_2d" and is_equal_approx(play.room.player.position.x, 1600.0), "Native v1 restore uses side travel spawn")
	_suite.expect(setup.session.snapshot() == state, "Native legacy world restore preserves imported progression")


func _walk_to(room: Node, target_x: float) -> void:
	var start := Time.get_ticks_msec()
	while absf(room.player.position.x - target_x) > 8.0 and Time.get_ticks_msec() - start < 20000:
		var right: bool = room.player.position.x < target_x
		Input.action_release("move_left" if right else "move_right")
		Input.action_press("move_right" if right else "move_left")
		await physics_frame
	_release_walk()
	for _frame: int in 8:
		await physics_frame
	_suite.expect(absf(room.player.position.x - target_x) < 40.0 and _inside(room), room._config.id + ": input walk reaches x=" + str(target_x))


func _sample_walk(room: Node) -> Dictionary:
	var samples: Array[float] = []
	var start := Time.get_ticks_usec()
	var previous := start
	var start_x: float = room.player.position.x
	var min_x: float = room._config.bounds.min_x + 200.0
	var max_x: float = room._config.bounds.max_x - 200.0
	var right := start_x < (min_x + max_x) / 2.0
	var inside := true
	while Time.get_ticks_usec() - start < 10000000:
		if room.player.position.x >= max_x:
			right = false
		elif room.player.position.x <= min_x:
			right = true
		Input.action_release("move_left" if right else "move_right")
		Input.action_press("move_right" if right else "move_left")
		await process_frame
		var now := Time.get_ticks_usec()
		samples.append(float(now - previous) / 1000.0)
		previous = now
		inside = inside and _inside(room)
	_release_walk()
	await _frames(8)
	samples.sort()
	_suite.expect(inside and absf(room.player.position.x - start_x) > 20.0, room._config.id + ": ten-second native walk moves within bounds")
	return {"seconds": float(previous - start) / 1000000.0, "frames": samples.size(), "frame_p95_ms": samples[ceili(samples.size() * 0.95) - 1]}


func _inside(room: Node) -> bool:
	return is_finite(room.player.position.x) and room.player.position.x >= room._config.bounds.min_x and room.player.position.x <= room._config.bounds.max_x and is_equal_approx(room.player.position.y, room._config.floor_y)


func _release_walk() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")


func _tap(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	root.push_input(event)
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame


func _frames(count: int) -> void:
	for _frame: int in count:
		await process_frame
