extends "res://tests/test_suite.gd"

const ROOM = preload("res://src/world/side/side_room.tscn")
const TARGETS = preload("res://src/world/side/side_targets.gd")
const LAYERS = preload("res://src/world/side/side_layers.gd")


func _manifest() -> Dictionary:
	return {
		"schema_version": 1,
		"assets": {
			"greybox.sky": {"kind": "greybox", "color": "#8fb4d8", "size": [3000.0, 600.0]},
			"greybox.wall": {"kind": "greybox", "color": "#c9b79a", "size": [3000.0, 900.0]},
			"greybox.pillar": {"kind": "greybox", "color": "#5a4a3a", "size": [80.0, 700.0]},
			"greybox.desk": {"kind": "greybox", "color": "#7a5a3a", "size": [200.0, 90.0]},
			"greybox.fg": {"kind": "greybox", "color": "#202020", "size": [400.0, 300.0]},
		},
	}


func _tuning() -> Dictionary:
	return {
		"max_speed": 360.0, "accel_time": 0.10, "decel_time": 0.08, "stride": 180.0, "bob": 4.0,
		"camera_dead_zone": 120.0, "camera_response": 0.08, "actor_height": 300.0, "actor_half_width": 40.0,
	}


func _room() -> Dictionary:
	return {
		"kind": "side_room_v1",
		"id": "corridor_c_2d",
		"location_id": "school",
		"title_key": "ui.common.quit",
		"height": 1080.0,
		"bounds": {"min_x": 0.0, "max_x": 3000.0},
		"floor_y": 900.0,
		"default_spawn": "left",
		"spawns": {"left": {"x": 400.0, "facing": 1}, "right": {"x": 2600.0, "facing": -1}},
		"layers": [
			{"id": "sky", "plane": "sky", "scroll_scale": 0.3, "art_ref": "greybox.sky", "position": [0.0, 0.0], "z": -100},
			{"id": "wall", "plane": "back", "scroll_scale": 1.0, "art_ref": "greybox.wall", "position": [0.0, 0.0], "z": -50},
			{"id": "fg", "plane": "foreground", "scroll_scale": 1.2, "art_ref": "greybox.fg", "position": [0.0, 780.0], "z": 0},
		],
		"props": [
			{"id": "pillar", "art_ref": "greybox.pillar", "position": [1600.0, 960.0], "sort_y": 960.0, "occludes_actor": true},
			{"id": "desk", "art_ref": "greybox.desk", "position": [1000.0, 880.0], "sort_y": 880.0, "occludes_actor": false},
			{"id": "poster", "art_ref": "greybox.desk", "position": [1300.0, 700.0], "sort_y": 700.0, "occludes_actor": false},
			{"id": "beam", "art_ref": "greybox.pillar", "position": [2000.0, 1100.0], "sort_y": 1100.0, "occludes_actor": true},
		],
		"doors": [
			{"id": "to_hall", "x": 200.0, "width": 120.0, "target_room": "hall_2d", "target_spawn": "from_corridor"},
			{"id": "to_club", "x": 2800.0, "width": 120.0, "target_room": "room3_2d", "target_spawn": "from_corridor", "target_location": "club"},
		],
		"interactions": [
			{"id": "board", "x": 900.0, "width": 100.0, "label_key": "ui.common.quit", "anchor_y": 700.0},
			{"id": "notice", "x": 2500.0, "width": 100.0, "label_key": "ui.common.quit", "anchor_y": 700.0},
		],
		"actors": [{"id": "van", "actor_ref": "van", "x": 1200.0, "facing": -1}],
		"lighting_ref": "corridor_lighting",
	}


func _frames(count: int) -> void:
	for _frame: int in count:
		await Engine.get_main_loop().physics_frame


func _z(node: Node2D) -> int:
	var parent := node.get_parent()
	return node.z_index + (parent.z_index if parent is Parallax2D else 0)


func _canvas_x(room: Node, id: String) -> float:
	return room.find_child(id, true, false).get_global_transform_with_canvas().origin.x


func _check_parallax(room: Node) -> void:
	var zoom: float = room.camera.zoom.x
	expect(not is_equal_approx(zoom, 1.0), "Parallax fixture runs under a non-1 zoom")
	room.place_player("left", 400.0)
	await Engine.get_main_loop().process_frame
	expect(is_equal_approx(room.camera.left_edge(), 0.0), "Camera rests on the left limit")
	expect(absf(_canvas_x(room, "sky")) < 0.5, "Parallax layer left edge aligns at the left limit")
	expect(absf(_canvas_x(room, "wall")) < 0.5, "Play-plane layer left edge aligns at the left limit")
	room.place_player("left", 1500.0)
	await Engine.get_main_loop().process_frame
	var left: float = room.camera.left_edge()
	expect(left > 0.0, "Camera scrolled mid-room")
	expect(absf(_canvas_x(room, "sky") - (-0.3 * left * zoom)) < 0.5, "Parallax layer scrolls at its scroll_scale mid-room")
	expect(absf(_canvas_x(room, "fg") - (-1.2 * left * zoom)) < 0.5, "Foreground layer scrolls faster mid-room")
	expect(absf(_canvas_x(room, "wall") - (-left * zoom)) < 0.5, "Play-plane layer tracks the camera mid-room")


func _interact(room: Node) -> void:
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	room._unhandled_input(event)


func run() -> void:
	expect(TARGETS.nearest([{"id": "a", "x": 0.0, "width": 10.0}, {"id": "b", "x": 8.0, "width": 20.0}], 6.0) == "b", "Nearest covering target wins")
	expect(TARGETS.nearest([{"id": "a", "x": 0.0, "width": 10.0}], 6.0) == "", "No covering target yields empty id")
	var config := _room()
	config.manifest = _manifest()
	config.tuning = _tuning()
	var room := ROOM.instantiate()
	room.configure(config, {"van": {}}, {})
	Engine.get_main_loop().root.add_child(room)
	await _frames(2)
	expect(room.KIND == "side_room_v1", "Side room kind constant")
	expect(room.player.position.x == 400.0, "Player mounts at default spawn x")
	expect(room.player.position.y == 900.0, "Player stands on floor_y")
	var before: float = room.player.position.x
	Input.action_press("move_right")
	await _frames(12)
	Input.action_release("move_right")
	expect(room.player.position.x > before, "move_right walks the player right")
	room.set_input_enabled(false)
	before = room.player.position.x
	Input.action_press("move_right")
	await _frames(12)
	Input.action_release("move_right")
	expect(room.player.position.x == before, "Disabled input does not move the player")
	room.set_input_enabled(true)

	var nearby: Array = []
	var interactions: Array = []
	var doors: Array = []
	var portals: Array = []
	var menus: Array = []
	room.nearby_changed.connect(func(id: String) -> void: nearby.append(id))
	room.interaction_requested.connect(func(id: String) -> void: interactions.append(id))
	room.door_requested.connect(func(target: String, spawn: String) -> void: doors.append([target, spawn]))
	room.portal_requested.connect(func(location: String, spawn: String) -> void: portals.append([location, spawn]))
	room.menu_requested.connect(func() -> void: menus.append(true))
	room.place_player("left", 900.0)
	await _frames(4)
	expect(nearby == ["board"], "nearby_changed emits the interaction id once")
	_interact(room)
	expect(interactions == ["board"], "Interact emits interaction_requested")
	expect(room.target_label_key("board") == "ui.common.quit", "Label key comes from content")
	await Engine.get_main_loop().process_frame
	var anchor: Dictionary = room.anchor_for("board")
	expect(anchor.visible and anchor.position is Vector2, "On-screen target anchor is visible")
	expect(not room.anchor_for("notice").visible, "Off-screen target anchor is hidden")
	expect(not room.anchor_for("missing").visible, "Unknown anchor hidden")

	room.place_player("left", 200.0)
	await _frames(2)
	expect(nearby == ["board", ""], "Leaving the target clears nearby")
	_interact(room)
	expect(doors == [["hall_2d", "from_corridor"]] and portals.is_empty(), "Same-location door emits door_requested")
	room.place_player("left", 2800.0)
	await _frames(2)
	_interact(room)
	expect(portals == [["club", "from_corridor"]] and doors.size() == 1, "Cross-location door emits portal_requested")
	room.set_input_enabled(false)
	_interact(room)
	var menu := InputEventAction.new()
	menu.action = "menu"
	menu.pressed = true
	room._unhandled_input(menu)
	expect(portals.size() == 1 and doors.size() == 1 and menus.is_empty(), "Locked input emits no door, portal or menu")
	room.set_input_enabled(true)
	room._unhandled_input(menu)
	expect(menus.size() == 1, "Menu action emits menu_requested")

	room.place_player("missing", NAN)
	expect(room.player.position.x == 400.0 and room.player.facing == 1, "Unknown spawn falls back to default")
	room.place_player("right", -5000.0)
	expect(room.player.position.x == 2600.0 and room.player.facing == -1, "Out-of-bounds x falls back to spawn")
	var safe: float = room.safe_spawn_x(1e9)
	expect(safe <= 3000.0 and safe >= 0.0, "safe_spawn_x clamps inside bounds")
	expect(room.accepts_saved_room("corridor_c_2d") and not room.accepts_saved_room("newsroom"), "Saved room id match")

	var pillar: Node2D = room.find_child("pillar", true, false)
	var desk: Node2D = room.find_child("desk", true, false)
	expect(pillar.z_index > room.player.z_index, "Occluding prop draws above the actor")
	expect(desk.z_index < room.player.z_index, "Background prop draws behind the actor")
	expect(room.find_child("sky", true, false).get_parent() is Parallax2D, "Slow layer scrolls through Parallax2D")
	expect(not room.find_child("wall", true, false).get_parent() is Parallax2D, "Play-plane layer is not parallaxed")
	var poster: Node2D = room.find_child("poster", true, false)
	var beam: Node2D = room.find_child("beam", true, false)
	var wall: Node2D = room.find_child("wall", true, false)
	var fg: Node2D = room.find_child("fg", true, false)
	expect(_z(poster) > _z(wall) and _z(poster) < room.player.z_index, "Wall prop draws above the back layer and below the actor")
	expect(_z(beam) > room.player.z_index and _z(beam) < _z(fg), "Deep occluder stays below the foreground layer")
	expect(_z(desk) > _z(poster), "Props order by sort_y")
	expect(_z(room.find_child("sky", true, false)) < _z(wall), "Planes keep their band order")
	expect(LAYERS.layer_z("back", 99999) < LAYERS.prop_z(0.0, 900.0, false), "Authored layer z cannot enter the actor band")
	expect(LAYERS.layer_z("foreground", -99999) > LAYERS.prop_z(99999.0, 900.0, true), "Foreground stays above every occluder")
	await _check_parallax(room)

	var van: Node2D = room.find_child("van", true, false)
	expect(van.position == Vector2(1200.0, 900.0) and van.facing == -1, "NPC placeholder stands at authored x")
	room.set_actor_talking("van", true)
	expect(van.facing == 1, "Talking NPC turns toward the player")
	room.set_actor_talking("van", false)
	expect(van.facing == -1, "NPC restores authored facing")
	room.set_reduced_motion(true)
	room.set_quality("low")
	expect(room.quality == "low", "Quality id retained for lighting consumers")
	room.queue_free()
	await Engine.get_main_loop().process_frame
