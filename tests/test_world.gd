extends "res://tests/test_suite.gd"

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")


func run() -> void:
	var setup := STARTUP.prepare()
	expect(setup.ok, "World composition content loads")
	if not setup.ok:
		return
	var room := ROOM.instantiate()
	room.configure(setup.data.room, setup.data.actors.actors, STARTUP.actor_textures(setup.data))
	Engine.get_main_loop().root.add_child(room)
	for _frame: int in 12:
		await Engine.get_main_loop().physics_frame
	var initial: Dictionary = setup.session.snapshot()
	expect(room.player.is_on_floor(), "Player rests on floor")
	expect(room.player.get_node("Rig/Sprite").sprite_frames.get_frame_count("walk_up") == 8, "Eight preserved directional walk frames")
	expect(room.player.get_node("Rig/Sprite").texture_filter == BaseMaterial3D.TEXTURE_FILTER_NEAREST, "Nearest atlas filtering")
	expect(room.player.get_node("Rig/Sprite").alpha_cut == SpriteBase3D.ALPHA_CUT_DISCARD, "Opaque alpha depth")
	var before: Vector3 = room.player.position
	Input.action_press("move_right")
	for _frame: int in 12:
		await Engine.get_main_loop().physics_frame
	Input.action_release("move_right")
	expect(room.player.position.distance_to(before) > 0.1, "Movement input changes spatial position")
	expect(setup.session.snapshot() == initial, "Walking leaves gameplay day/energy unchanged")
	room.set_input_enabled(false)
	before = room.player.position
	Input.action_press("move_left")
	for _frame: int in 12:
		await Engine.get_main_loop().physics_frame
	Input.action_release("move_left")
	expect(Vector2(room.player.position.x - before.x, room.player.position.z - before.z).length() < 0.001, "Injected input lock stops motion")
	room.set_input_enabled(true)
	# Repeatedly push directly through a table at a fixed, authored test point.
	room.player.set_physics_process(false)
	room.player.position = Vector3(-1, 0.05, 1.6)
	for _frame: int in 90:
		room.player.velocity = Vector3(0, -0.3, -3)
		room.player.move_and_slide()
		await Engine.get_main_loop().physics_frame
	expect(room.player.position.z >= 0.26, "Table collider blocks penetration")
	expect(room.safe_spawn(Vector3(-1, 0.05, -0.6)) == Vector3(0, 0.05, 2.9), "Blocked spawn falls back")
	expect(room.safe_spawn(Vector3(99, 0, 99)) == Vector3(0, 0.05, 2.9), "Unknown/outside spawn falls back")
	room.player.position = Vector3(2.7, 0.05, 0.1)
	for _frame: int in 4:
		await Engine.get_main_loop().physics_frame
	var van := room.get_node("Target_van")
	expect(van.player_nearby(room.player), "Area detects player near authored target ID")
	var observed: Array = []
	room.interaction_requested.connect(func(id: String) -> void: observed.append(id))
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	room._unhandled_input(interact)
	expect(observed == ["van"], "Interaction emits stable target ID")
	var anchor: Dictionary = room.anchor_for("van")
	expect(anchor.has("position"), "World anchor projects to native UI plane")
	expect(not room.anchor_for("missing").visible, "Unknown anchor hidden")
	room.set_camera_preset("perspective")
	expect(room.camera.projection == Camera3D.PROJECTION_PERSPECTIVE and room.camera.fov == 25, "Perspective comparison preset")
	room.set_camera_preset("orthographic")
	room.set_actor_talking("van", true)
	expect(room.get_node("Actor_van/Sprite").animation == "talk_down", "NPC local talk clip")
	room.set_actor_talking("van", false)
	var portal_events: Array = []
	room.portal_requested.connect(func(id: String, portal: String) -> void: portal_events.append([id, portal]))
	room.player.position = Vector3(0, 0.05, 4.25)
	for _frame: int in 5:
		await Engine.get_main_loop().physics_frame
	expect(portal_events == [["yard", "newsroom-to-yard"]], "Portal contract emits destination and stable ID")
	var mapping := {"move_left": KEY_LEFT, "move_right": KEY_RIGHT, "move_up": KEY_UP, "move_down": KEY_DOWN}
	for action: String in mapping:
		expect(InputMap.action_get_events(action).any(func(e: InputEvent) -> bool: return e is InputEventKey and e.physical_keycode == mapping[action]), "Arrow input binding: " + action)
	room.queue_free()
	await Engine.get_main_loop().process_frame
