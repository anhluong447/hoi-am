extends "res://tests/test_suite.gd"

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const STORE = preload("res://src/infrastructure/saves/file_save_store.gd")
const SAVES = preload("res://src/application/gameplay_saves.gd")
const CONTRACT = preload("res://src/domain/gameplay/save_contract.gd")
const FORMULA = preload("res://src/domain/formula_sandbox/formula_rules.gd")
const FORMULA_VALIDATOR = preload("res://src/domain/formula_sandbox/formula_validation.gd")
const FORMULA_SAVES = preload("res://src/application/formula_saves.gd")
const SESSION = preload("res://src/application/game_session.gd")
const COMPARE = preload("res://tests/parity_compare.gd")
const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const FIXTURES := "res://tests/fixtures/saves/"


func run() -> void:
	var setup := STARTUP.prepare()
	var store := STORE.new("res://artifacts/tests/saves")
	var service := SAVES.new(setup.session, setup.data.gameplay, store.read_slot, store.write_slot, setup.validator.validate)
	var world := {"version": 1, "location_id": "club", "room_id": "newsroom_sample", "position": [1.0, 0.05, 2.0]}
	var initial: Dictionary = setup.session.snapshot()
	expect(service.save("slot_1", world, "2026-10-10T12:00:00").ok, "Native save writes")
	setup.session.execute({"type": "school"})
	var changed: Dictionary = setup.session.snapshot()
	var loaded := service.load_slot("slot_1")
	expect(loaded.ok and COMPARE.difference(world, loaded.get("world", {})).is_empty() and COMPARE.difference(initial, setup.session.snapshot()).is_empty(), "JSON round-trip semantic equality " + str(loaded))
	expect(service.save("slot_1", world, "2026-10-10T12:01:00").ok and FileAccess.file_exists("res://artifacts/tests/saves/slot_1.json.bak"), "Previous revision preserved as backup")
	var interrupted := FileAccess.open("res://artifacts/tests/saves/slot_1.json.tmp", FileAccess.WRITE)
	interrupted.store_string("{broken")
	interrupted.close()
	expect(service.load_slot("slot_1").ok, "Interrupted temporary write never replaces committed save")
	var payload := CONTRACT.envelope(initial, world, "2026-10-10")
	for pair: Array in [["ruleset", "formula_sandbox"], ["content_version", 99], ["envelope_version", 99], ["state", {}], ["world", {}]]:
		var corrupt := payload.duplicate(true)
		corrupt[pair[0]] = pair[1]
		expect(not service.import_payload(corrupt).ok and COMPARE.difference(initial, setup.session.snapshot()).is_empty(), "Reject save corruption without replacement " + pair[0])
	var corrupt := payload.duplicate(true)
	corrupt.world.position[0] = NAN
	expect(not service.import_payload(corrupt).ok, "Reject nonfinite world coordinates")
	corrupt = payload.duplicate(true)
	corrupt.state.people[0].stats.photo = "bad"
	expect(not service.import_payload(corrupt).ok and COMPARE.difference(initial, setup.session.snapshot()).is_empty(), "Validate state before live replacement")
	var legacy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/parity/calendar-weekend.json")).initial
	expect(service.import_payload(legacy).ok and COMPARE.difference(initial, setup.session.snapshot()).is_empty(), "Legacy raw v2")
	legacy.version = 1
	expect(service.import_payload({"state": legacy, "world": {"mapId": "club", "x": 8, "y": 6}}).ok, "Legacy wrapped v1 pixel import")
	expect(service.import_payload({"kind": "press-gameplay-save", "version": 1, "contentVersion": 1, "mode": "pixel", "state": legacy, "world": {"mapId": "unknown"}}).ok, "Browser envelope import with safe location mapping")
	expect(not service.save("../escape", world, "now").ok, "Reject unsafe slot path")
	var failed_service := SAVES.new(setup.session, setup.data.gameplay, store.read_slot, func(_slot: String, _value: Dictionary) -> Dictionary: return {"ok": false, "error": {"code": "disk_full", "text_key": "save.invalid"}}, setup.validator.validate)
	expect(not failed_service.save("slot_1", world, "now").ok and COMPARE.difference(initial, setup.session.snapshot()).is_empty(), "Write failure preserves session")
	var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/formula_sandbox/pack.json"))
	var formula := FORMULA.new(pack)
	var validator := FORMULA_VALIDATOR.new(pack, setup.data.catalog)
	var session := SESSION.new(formula.transition, validator.validate)
	session.replace(formula.create_session())
	var formula_saves := FORMULA_SAVES.new(session, store.read_slot, store.write_slot)
	var formula_saved := formula_saves.save("slot_2")
	var formula_loaded := formula_saves.load_slot("slot_2")
	expect(formula_saved.ok and formula_loaded.ok, "Formula own contract round-trip " + str(formula_loaded))
	expect(not service.load_slot("slot_2").ok and not formula_saves.load_slot("slot_1").ok, "Ruleset isolation in both directions")
	var broken := FileAccess.open("res://artifacts/tests/saves/slot_3.json", FileAccess.WRITE)
	broken.store_string("{broken")
	broken.close()
	expect(not service.load_slot("slot_3").ok, "Corrupt disk JSON reports failure")
	setup.session.replace(changed)
	await _world_envelopes()


func _fixture(name: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FIXTURES + name + ".json"))
	return parsed if parsed is Dictionary else {}


func _settle(tree: SceneTree) -> void:
	for _frame: int in 3:
		await tree.physics_frame


func _restore(tree: SceneTree, play: Node, world: Dictionary) -> void:
	await play.restore_world(world)
	await _settle(tree)


## World envelope v2 (side x/facing or HD-2D position) and v1/legacy fallbacks,
## exercised through the real Playable, GameplaySaves and save_contract.
func _world_envelopes() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var play := PLAY.instantiate()
	tree.root.add_child(play)
	await _settle(tree)
	var setup: Dictionary = play.setup
	var maps: Dictionary = setup.data.locations.legacy_maps
	var store := STORE.new("res://artifacts/tests/saves")
	var service := SAVES.new(setup.session, setup.data.gameplay, store.read_slot, store.write_slot, setup.validator.validate, maps)
	var club := _fixture("world_v1_club_3d")
	expect(club.get("world", {}).get("room_id") == "newsroom_hd2d_v1" and club.world.position.size() == 3, "Genuine v1 club fixture keeps the pre-pivot HD-2D shape")
	var decoded := CONTRACT.decode(club, setup.data.gameplay, maps)
	var loaded := service.import_payload(club)
	expect(decoded.ok and loaded.ok and COMPARE.difference(decoded.state, setup.session.snapshot()).is_empty() and loaded.world == club.world, "v1 club 3D save decodes and replaces state unchanged " + str(loaded.get("error", "")))
	var state: Dictionary = setup.session.snapshot()
	await _restore(tree, play, loaded.get("world", {}))
	expect(play.controller.location_id == "club" and play.room._config.id == "room3_2d" and is_equal_approx(play.room.player.position.x, 1600.0) and play.room.player.facing == 1, "v1 club 3D position falls back to the room3_2d travel spawn")
	expect(setup.session.snapshot() == state, "World restore leaves gameplay state unchanged")
	var library := _fixture("world_v1_library_3d")
	loaded = service.import_payload(library)
	await _restore(tree, play, loaded.get("world", {}))
	var saved: Array = library.world.position
	expect(loaded.ok and play.controller.location_id == "library" and play.room.player.position.distance_to(Vector3(saved[0], saved[1], saved[2])) < 0.05, "v1 HD-2D library save restores its position")
	var world: Dictionary = play.world_snapshot()
	expect(world.version == 2 and world.room_id == "library_hd2d_v1" and world.position.size() == 3 and not world.has("x") and CONTRACT.valid_world(world), "HD-2D rooms snapshot v2 with position " + str(world))
	loaded = service.import_payload(_fixture("world_v1_side_school"))
	await _restore(tree, play, loaded.get("world", {}))
	expect(loaded.ok and play.room._config.id == "school_gate_2d" and is_equal_approx(play.room.player.position.x, 1500.0), "v1 side save enters the location entry room travel spawn")
	var v1_extra := _fixture("world_v1_side_school")
	v1_extra.world.x = 1234.0
	loaded = service.import_payload(v1_extra)
	expect(loaded.ok, "v1 accepts unknown extra fields without changing its decoder version")
	var before_restore: Dictionary = setup.session.snapshot()
	await _restore(tree, play, loaded.get("world", {}))
	expect(play.room._config.id == "school_gate_2d" and is_equal_approx(play.room.player.position.x, 1500.0) and setup.session.snapshot() == before_restore, "v1 with extra x and no facing uses legacy spawn without changing progression")
	await _side_round_trip(tree, play, service)
	for bad: Dictionary in [{"x": NAN}, {"x": INF}, {"x": "1234"}, {"facing": 0}, {"facing": 2}, {"facing": "1"}, {"position": [1.0, 0.0, 2.0]}, {"version": 3}, {"room_id": 4}]:
		world = {"version": 2, "location_id": "school", "room_id": "corridor_c_2d", "x": 1234.0, "facing": -1}
		world.merge(bad, true)
		expect(not CONTRACT.valid_world(world), "Invalid v2 world rejected " + str(bad))
	expect(not CONTRACT.valid_world({"version": 2, "location_id": "school", "room_id": "corridor_c_2d"}), "v2 world needs x/facing or position")
	expect(not CONTRACT.valid_world({"version": 2, "location_id": "school", "room_id": "corridor_c_2d", "x": 1.0}), "v2 side world needs facing")
	expect(not CONTRACT.valid_world({"version": 2, "location_id": "library", "room_id": "library_hd2d_v1", "position": [0.0, NAN, 1.0]}), "v2 HD-2D world needs finite position")
	for name: String in ["world_v2_corrupt_x", "world_v2_both_fields"]:
		var before: Dictionary = setup.session.snapshot()
		var result := CONTRACT.decode(_fixture(name), setup.data.gameplay)
		expect(not result.ok and result.error.code == "invalid_save_envelope" and not service.import_payload(_fixture(name)).ok and setup.session.snapshot() == before, name + " rejected without replacement")
	var legacy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/parity/calendar-weekend.json")).initial
	legacy.version = 1
	loaded = service.import_payload({"state": legacy, "world": {"mapId": "yard", "x": 8, "y": 6}})
	expect(loaded.ok and loaded.world == CONTRACT.legacy_world({"mapId": "yard"}, maps) and loaded.world.version == 1, "Legacy tile save still maps through legacy_world")
	await _restore(tree, play, loaded.get("world", {}))
	expect(play.controller.location_id == "school" and play.room._config.id == "school_gate_2d" and is_equal_approx(play.room.player.position.x, 1500.0), "Legacy tile save enters the mapped location travel spawn")
	loaded = service.import_payload({"kind": "press-gameplay-save", "version": 1, "contentVersion": 1, "mode": "pixel", "state": legacy, "world": {"mapId": "newsroom"}})
	expect(loaded.ok and loaded.world == {"version": 1, "location_id": "club", "room_id": "legacy_tile"}, "Legacy press save still maps through legacy_world")
	setup.session.replace(state)
	play.queue_free()
	await tree.process_frame


func _side_round_trip(tree: SceneTree, play: Node, service: RefCounted) -> void:
	play.travel("school")
	play.enter_room("corridor_c_2d", "from_gate")
	await _settle(tree)
	play.room.place_player("from_gate", 1234.0, -1)
	var world: Dictionary = play.world_snapshot()
	expect(world == {"version": 2, "location_id": "school", "room_id": "corridor_c_2d", "x": 1234.0, "facing": -1}, "Side rooms snapshot v2 x/facing " + str(world))
	expect(service.save("slot_1", world, "2026-10-28T00:00:00").ok, "v2 side world saves")
	play.travel("library")
	await _settle(tree)
	var loaded: Dictionary = service.load_slot("slot_1")
	await _restore(tree, play, loaded.get("world", {}))
	expect(loaded.ok and play.room._config.id == "corridor_c_2d" and play.controller.location_id == "school" and is_equal_approx(play.room.player.position.x, 1234.0) and play.room.player.facing == -1 and play.room._input_enabled, "v2 side save round-trips room, x and facing")
	var fixture := _fixture("world_v2_side")
	loaded = service.import_payload(fixture)
	play.travel("club")
	await _restore(tree, play, loaded.get("world", {}))
	expect(loaded.ok and play.room._config.id == fixture.get("world", {}).get("room_id") and is_equal_approx(play.room.player.position.x, 1234.0) and play.room.player.facing == -1, "world_v2_side fixture restores x=1234 facing -1 in its room")
	await _restore(tree, play, {"version": 2, "location_id": "school", "room_id": "corridor_c_2d", "x": 99999.0, "facing": -1})
	expect(play.room._config.id == "corridor_c_2d" and is_equal_approx(play.room.player.position.x, 300.0), "v2 x outside room bounds clamps to the default spawn")
	await _restore(tree, play, {"version": 2, "location_id": "club", "room_id": "newsroom_hd2d_v1", "position": [0.0, 0.05, 2.9]})
	expect(play.room._config.id == "room3_2d" and is_equal_approx(play.room.player.position.x, 1600.0), "Old HD-2D room at a now-side location uses the travel spawn")
	await _restore(tree, play, {"version": 2, "location_id": "club", "room_id": "corridor_c_2d", "x": 500.0, "facing": 1})
	expect(play.controller.location_id == "club" and play.room._config.id == "room3_2d" and is_equal_approx(play.room.player.position.x, 1600.0), "v2 room from another location falls back to the travel spawn")
