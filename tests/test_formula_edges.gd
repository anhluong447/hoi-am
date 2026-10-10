extends "res://tests/test_suite.gd"

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const RULES = preload("res://src/domain/formula_sandbox/formula_rules.gd")
const VALIDATOR = preload("res://src/domain/formula_sandbox/formula_validation.gd")
const CONFIG = preload("res://src/domain/formula_sandbox/formula_config.gd")
const MATH = preload("res://src/domain/formula_sandbox/formula_math.gd")
const SESSION = preload("res://src/application/game_session.gd")


func run() -> void:
	var setup := STARTUP.prepare()
	var pack: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/formula_sandbox/pack.json"))
	var rules := RULES.new(pack)
	var validator := VALIDATOR.new(pack, setup.data.catalog)
	var session := SESSION.new(rules.transition, validator.validate)
	session.replace(rules.create_session())
	var initial := session.snapshot()
	for command: Dictionary in [{"type": "closeWeek"}, {"type": "select", "ids": ["missing"]}, {"type": "scout", "id": "future"}, {"type": "interview", "id": "W01-S01", "reporter": "khue", "supporter": "khue"}]:
		expect(not session.execute(command).ok and session.snapshot() == initial, "Formula guard/ownership " + str(command.type))
	var result := session.execute({"type": "debug", "patch": {"fatigue": {"khue": 100}, "joinWeek": {"nhi": 1}, "pressure": 159}})
	expect(result.ok and result.state.staff[3].joinWeek == 1 and result.state.fatigue.khue == 100 and result.events[0].type == "debug", "Explicit formula patches preserve source behavior")
	var prior := session.snapshot()
	for patch: Dictionary in [{"fatigue": {"khue": 101}}, {"joinWeek": {"nhi": 0}}, {"energy": 5}, {"suspendedNextWeek": 1}, {"pressure": NAN}]:
		expect(not session.execute({"type": "debug", "patch": patch}).ok and session.snapshot() == prior, "Invalid debug patch rejects atomically")
	for pair: Array in [[39.99, 0], [40, 1], [79.99, 1], [80, 2], [100, 2]]:
		var state := rules.create_session()
		state.week = 3
		state.day = 15
		state.pressure = pair[0] / state.config.pressureDecay
		expect(MATH.preview(state).strike == pair[1], "Scheduled strike boundary " + str(pair[0]))
	var state := rules.create_session()
	state.day = 5
	state.pressure = 200
	session.replace(state)
	var next := session.execute({"type": "next"})
	expect(next.ok and next.state.suspendedNextWeek and next.state.difficultyOffset == 1 and absf(next.state.pressure - 51) < 1e-8, "Emergency strike carries pressure and suspends following issue")
	state = next.state
	state.day = 10
	state.week = 2
	session.replace(state)
	next = session.execute({"type": "next"})
	expect(next.ok and not next.state.suspendedNextWeek and next.state.reports[-1].suspensionMultiplier == 0.5, "Suspension consumed by one following issue")
	session.replace(rules.create_session())
	for _day: int in 16:
		if session.snapshot().outcome != null:
			break
		session.execute({"type": "next"})
	expect(session.snapshot().outcome == "disbanded" and session.snapshot().reports.size() == 3 and not session.execute({"type": "next"}).ok, "Empty campaign disbands and blocks further actions")
	state = rules.create_session()
	state.day = 61
	state.week = 12
	expect(MATH.outcome(state) == "defeat", "Ending evidence threshold")
	state.evidence = 200
	state.reputation = 54.99
	expect(MATH.outcome(state) == "bitter", "Ending reputation threshold")
	state.reputation = 55
	expect(MATH.outcome(state) == "win", "Ending both thresholds")
	for patch: Dictionary in [{"pressureCarry": 2}, {"dailyEnergy": 3.5}, {"slots": 3}, {"qualityCap": 0}, {"slotWeights": 1}, {"maxScore": []}]:
		var config: Dictionary = pack.config.duplicate(true)
		config.merge(patch, true)
		expect(not CONFIG.validate(config, pack.config), "Config guard " + str(patch.keys()))
