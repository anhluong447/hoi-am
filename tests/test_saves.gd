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
