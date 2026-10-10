extends "res://tests/test_suite.gd"

const RULES = preload("res://src/domain/gameplay/gameplay_rules.gd")
const VALIDATOR = preload("res://src/domain/gameplay/state_validation.gd")
const MIGRATION = preload("res://src/domain/gameplay/state_migration.gd")
const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const SESSION = preload("res://src/application/game_session.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const CATALOG = preload("res://src/shared/text_catalog.gd")
const COMPARE = preload("res://tests/parity_compare.gd")
const TEXT = preload("res://src/presentation/controllers/gameplay_text.gd")
const CONTENT_VALIDATOR = preload("res://src/domain/gameplay/content_validation.gd")


func run() -> void:
	var pack: Dictionary = LOADER.read_dictionary("res://content/gameplay/pack.json").data
	var locale: Dictionary = LOADER.read_dictionary("res://content/locales/vi.json").data
	var rules := RULES.new(pack)
	var validator := VALIDATOR.new(pack, locale)
	var catalog := CATALOG.new()
	catalog.set_catalog(locale)
	var comparator := COMPARE.new(catalog)
	var text := TEXT.new(catalog)
	expect(CONTENT_VALIDATOR.validate(pack, locale).ok, "Shipped pack validates independently")
	var invalid_pack := pack.duplicate(true)
	invalid_pack.roster.append(invalid_pack.roster[0])
	expect(not CONTENT_VALIDATOR.validate(invalid_pack, locale).ok, "Reject duplicate content IDs")
	invalid_pack = pack.duplicate(true)
	invalid_pack.cases[0].need = "missing"
	expect(not CONTENT_VALIDATOR.validate(invalid_pack, locale).ok, "Reject content stat references")
	invalid_pack = pack.duplicate(true)
	invalid_pack.balance.FATIGUE.divisor = 0
	expect(not CONTENT_VALIDATOR.validate(invalid_pack, locale).ok, "Reject zero tuning divisor")
	invalid_pack = pack.duplicate(true)
	invalid_pack.balance.DEFAULTS.erase("clubEnergy")
	expect(not CONTENT_VALIDATOR.validate(invalid_pack, locale).ok, "Reject missing runtime tuning field")
	var created := rules.create_session()
	expect(created.ok and validator.validate(created.state).ok, "Create valid gameplay state v3")
	var init_trace := _fixture("calendar-weekend")
	expect(COMPARE.difference(init_trace.initial, comparator.compatibility(created.state)).is_empty(), "Initial state source parity")
	for id: String in ["calendar-weekend", "guards", "final-day", "assignment-reassignment", "publication-once", "editorial-next-day"]:
		var trace := _fixture(id)
		var migrated := MIGRATION.migrate(trace.initial, pack)
		expect(migrated.ok, id + " migration")
		if not migrated.ok:
			continue
		var session := SESSION.new(rules.transition, validator.validate)
		var replacement := session.replace(migrated.state)
		expect(replacement.ok, id + " fixture validates: " + str(replacement.get("error", {})))
		if not replacement.ok:
			continue
		for index: int in trace.steps.size():
			var step: Dictionary = trace.steps[index]
			var before := session.snapshot()
			var result := session.execute(step.command)
			var prefix := "%s/%d: " % [id, index]
			expect(result.ok == step.ok, prefix + "accepted/rejected matches " + str(result.get("error", {})))
			var delta := COMPARE.difference(step.state, comparator.compatibility(session.snapshot()))
			expect(delta.is_empty(), prefix + delta)
			if step.ok and result.ok:
				var event_delta := COMPARE.difference(step.events, comparator.events(result.events))
				expect(event_delta.is_empty(), prefix + event_delta)
			elif not result.ok:
				expect(session.snapshot() == before, prefix + "rejection preserves live state")
				expect(text.text(result.error.text_key, result.error.get("parameters", {})) == step.error_text, prefix + "rejection copy source parity")
	_test_corruptions(created.state, rules, validator, pack)
	var v1: Dictionary = init_trace.initial.duplicate(true)
	v1.version = 1
	v1.people[0].skills = pack.legacy_skills.keys()
	var migrated := MIGRATION.migrate(v1, pack)
	expect(migrated.ok and migrated.state.people[0].skills == ["synergy"] and v1.version == 1, "v1 skills migrate without mutation")
	var candidate: Dictionary = created.state.people[1].duplicate(true)
	candidate.romance = true
	candidate.fatigue = 100
	var state: Dictionary = created.state.duplicate(true)
	state.betrayal = true
	expect(absf(PEOPLE.effective_stat(state, candidate, "documents", pack.balance.FATIGUE) - 3.4125) < 1e-8, "Fatigue floor and romance penalty")


func _test_corruptions(state: Dictionary, rules: RefCounted, validator: RefCounted, pack: Dictionary) -> void:
	var session := SESSION.new(rules.transition, validator.validate)
	session.replace(state)
	for pair: Array in [["day", 0], ["phase", "unknown"], ["money", -1], ["energy", true], ["version", 2], ["sleepPrepared", 1], ["boostToday", "false"], ["metrics", {}]]:
		var corrupt := state.duplicate(true)
		corrupt[pair[0]] = pair[1]
		expect(not session.replace(corrupt).ok and session.snapshot() == state, "Reject corruption " + pair[0])
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/invalid_states.json"))
	for mutation: Dictionary in fixture.mutations:
		var invalid := state.duplicate(true)
		var target: Variant = invalid
		for index: int in mutation.path.size() - 1:
			var key: Variant = mutation.path[index]
			target = target[int(key)] if target is Array else target[key]
		var final: Variant = mutation.path[-1]
		target[int(final) if target is Array else final] = mutation.value
		expect(not session.replace(invalid).ok and session.snapshot() == state, "Reject corrupt fixture " + str(mutation.path))
	var corrupt := state.duplicate(true)
	corrupt.people[0].id = "missing"
	expect(not validator.validate(corrupt).ok, "Reject unknown actor")
	corrupt = state.duplicate(true)
	corrupt.people[0].stats.photo = NAN
	expect(not validator.validate(corrupt).ok, "Reject nonfinite stat")
	corrupt = state.duplicate(true)
	corrupt.cases[0].owner = "missing"
	expect(not validator.validate(corrupt).ok, "Reject broken owner reference")
	corrupt = state.duplicate(true)
	corrupt.log[0].textKey = "missing"
	expect(not validator.validate(corrupt).ok, "Reject missing catalog key")
	corrupt = state.duplicate(true)
	corrupt.log[0].params = {"loop": Node.new()}
	expect(not validator.validate(corrupt).ok, "Reject scene object from domain state")
	corrupt.log[0].params.loop.free()
	var snapshot := session.snapshot()
	snapshot.people[0].stats.photo = 100
	expect(session.snapshot() == state, "Live gameplay snapshot owned")
	var result := session.execute({"type": "school"})
	result.state.money = 999
	result.events[0].params.injected = true
	expect(session.snapshot().money == state.money and not session.snapshot().log[-1].params.has("injected"), "Gameplay result/events owned")
	for command: String in ["quest", "write", "date", "gift", "tool", "boost", "upgrade"]:
		var prior := session.snapshot()
		expect(session.execute({"type": command}).error.code == "command_not_ported" and session.snapshot() == prior, "Unported command rejects: " + command)
	expect(not rules.create_session({"days": 13}).ok, "Reject invalid config days")
	expect(not MIGRATION.migrate({"version": 4}, pack).ok, "Reject future version")


func _fixture(id: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/parity/" + id + ".json"))
