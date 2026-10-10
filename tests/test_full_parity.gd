extends "res://tests/test_suite.gd"

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const SESSION = preload("res://src/application/game_session.gd")
const COMPARE = preload("res://tests/parity_compare.gd")
const SUMMARY = preload("res://src/domain/gameplay/gameplay_summary.gd")
const RULES = preload("res://src/domain/formula_sandbox/formula_rules.gd")
const VALIDATOR = preload("res://src/domain/formula_sandbox/formula_validation.gd")
const POLICY = preload("res://src/domain/formula_sandbox/formula_policy.gd")

var _text: RefCounted


func run() -> void:
	var setup := STARTUP.prepare()
	_text = setup.text
	var comparator := COMPARE.new(setup.catalog)
	var results: Dictionary = {"gameplay": [], "formula": [], "float_tolerance": 1e-8}
	var gameplay: Array = _read("res://tests/fixtures/parity/gameplay-policies.json")
	var baseline: Dictionary = _read("res://docs/reference/hai-vong/gameplay-baseline.json")
	for index: int in gameplay.size():
		var fixture: Dictionary = gameplay[index]
		var created: Dictionary = setup.rules.create_session({"days": 84 if fixture.id == "mixed-84-days" else 14})
		var session := SESSION.new(setup.rules.transition, setup.validator.validate)
		expect(session.replace(created.state).ok, fixture.id + " initial validates")
		for command: Dictionary in fixture.commands:
			var result := session.execute(command)
			if not result.ok:
				expect(false, fixture.id + " command failed: " + str(command) + str(result))
				break
		var state := session.snapshot()
		expect(COMPARE.difference(fixture.state, comparator.compatibility(state)).is_empty(), fixture.id + " full state parity: " + COMPARE.difference(fixture.state, comparator.compatibility(state)))
		var summary := SUMMARY.summarize(state, setup.data.gameplay)
		summary.merge({"policy": fixture.id, "metrics": state.metrics, "reports": state.reports})
		expect(COMPARE.difference(baseline.policies[index], summary).is_empty(), fixture.id + " committed baseline parity")
		results.gameplay.append(summary)
	var pack: Dictionary = _read("res://content/formula_sandbox/pack.json")
	var rules := RULES.new(pack)
	var validator := VALIDATOR.new(pack, setup.data.catalog)
	var formula: Array = _read("res://tests/fixtures/parity/formula-policies.json")
	var formula_baseline: Array = _read("res://docs/reference/hai-vong/sandbox-baseline.json")
	for index: int in pack.policies.size():
		var policy: Dictionary = pack.policies[index]
		var session := SESSION.new(rules.transition, validator.validate)
		expect(session.replace(rules.create_session(policy.get("solo", false))).ok, policy.id + " formula initial validates")
		for _day: int in 61:
			if session.snapshot().outcome != null:
				break
			var result := POLICY.run_day(session, policy)
			if not result.ok:
				expect(false, policy.id + " formula command failed: " + str(result))
				break
		var state := session.snapshot()
		var expected: Dictionary = formula[index].state.duplicate(true)
		for person: Dictionary in expected.staff:
			person.erase("role")
		var actual: Dictionary = _compatibility(state)
		actual.version = 1
		var difference := COMPARE.difference(expected, actual)
		expect(difference.is_empty(), policy.id + " formula full state: " + difference)
		var score := 0.0
		var heavy := 0
		for report: Dictionary in state.reports:
			score += report.score
			heavy += 1 if report.strike == 2 else 0
		var row := {"policy": _text.text(policy.name_key), "outcome": state.outcome, "evidence": state.evidence,
			"reputation": state.reputation, "averageScore": score / state.reports.size(), "heavyStrikes": heavy}
		expect(COMPARE.difference(formula_baseline[index], row).is_empty(), policy.id + " formula baseline: " + COMPARE.difference(formula_baseline[index], row))
		results.formula.append(row)
		var corrupt := state.duplicate(true)
		corrupt.fatigue.khue = -1
		expect(not session.replace(corrupt).ok and session.snapshot() == state, "Formula rejects corruption without replacement")
	DirAccess.make_dir_recursive_absolute("res://artifacts/parity")
	var file := FileAccess.open("res://artifacts/parity/full-results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(results, "  "))
	file.close()


func _compatibility(value: Variant) -> Variant:
	if value is Array:
		return value.map(_compatibility)
	if not value is Dictionary:
		return value
	var result: Dictionary = value.duplicate(true)
	if result.has("text_key"):
		result.text = _text.text(result.text_key, result.params)
		result.erase("text_key")
		result.erase("params")
	for field: String in ["name", "label"]:
		if result.has(field + "_key"):
			result[field] = _text.text(result[field + "_key"], result.get(field + "_parameters", {}))
			result.erase(field + "_key")
			result.erase(field + "_parameters")
	for key: String in result:
		result[key] = _compatibility(result[key])
	return result


static func _read(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))
