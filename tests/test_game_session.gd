extends "res://tests/test_suite.gd"

const SESSION = preload("res://src/application/game_session.gd")

var _last_event: Dictionary = {}


func run() -> void:
	var session := SESSION.new(_transition, _validate)
	expect(not session.execute({"type": "advance"})["ok"], "Reject commands before initialization")
	var initial := {"ruleset": "fixture", "nested": {"value": 1}}
	expect(session.replace(initial)["ok"], "Initialize valid state")
	initial["nested"]["value"] = 80
	expect(session.snapshot()["nested"]["value"] == 1, "Replacement must not alias caller state")
	var snapshot := session.snapshot()
	snapshot["nested"]["value"] = 90
	expect(session.snapshot()["nested"]["value"] == 1, "Snapshot must not leak owned nested state")
	var command := {"type": "advance", "nested": {"value": 0}}
	var executed := session.execute(command)
	expect(executed["ok"], "Valid command succeeds")
	expect(command["nested"]["value"] == 0, "Command must not alias handler input")
	executed["state"]["nested"]["value"] = 70
	expect(session.snapshot()["nested"]["value"] == 2, "Result must not leak committed state")
	executed["events"][0]["parameters"]["value"] = 70
	expect(_last_event["parameters"]["value"] == 1, "Events must not alias transition-owned data")
	var before := session.snapshot()
	expect(not session.execute({"type": "reject"})["ok"], "Rejected transition fails")
	expect(session.snapshot() == before, "Rejected transition leaves owned state unchanged")
	expect(not session.execute({"type": "invalid"})["ok"], "Validate successful transition state")
	expect(session.snapshot() == before, "Invalid transition state must not commit")
	var rejected := session.replace({"ruleset": "other", "nested": {"value": 5}})
	expect(not rejected["ok"], "Ruleset validation")
	expect(rejected["error"]["code"] == "fixture_invalid", "Preserve validator error details")
	expect(session.snapshot() == before, "Invalid replacement must preserve live session")
	var malicious := SESSION.new(_transition, _mutating_validator)
	malicious.replace({"ruleset": "fixture", "nested": {"value": 1}})
	expect(malicious.snapshot()["nested"]["value"] == 1, "Validator must not alias committed state")
	var malformed := SESSION.new(func(_s: Dictionary, _c: Dictionary) -> Array: return [], _validate)
	malformed.replace(before)
	expect(not malformed.execute({})["ok"], "Reject malformed callback results")
	var loose := SESSION.new(func(_s: Dictionary, _c: Dictionary) -> Dictionary: return {"ok": "yes"}, _validate)
	loose.replace(before)
	expect(not loose.execute({})["ok"], "Reject non-boolean transition success")
	var loose_validator := SESSION.new(_transition, func(_s: Dictionary) -> Dictionary: return {"ok": "yes"})
	expect(not loose_validator.replace(before)["ok"], "Reject non-boolean validator success")


func _validate(state: Dictionary) -> Dictionary:
	var valid: bool = state.get("ruleset") == "fixture" and state.get("nested") is Dictionary
	if valid:
		valid = state["nested"].get("value") is int and state["nested"]["value"] >= 0
	return {"ok": true} if valid else {"ok": false, "error": {"code": "fixture_invalid"}}


func _mutating_validator(state: Dictionary) -> Dictionary:
	var result := _validate(state)
	state["nested"]["value"] = 999
	return result


func _transition(state: Dictionary, command: Dictionary) -> Dictionary:
	state["nested"]["value"] += 1
	if command.has("nested"):
		command["nested"]["value"] = 999
	if command.get("type") == "reject":
		return {"ok": false, "error": {"code": "fixture_rejected"}}
	if command.get("type") == "invalid":
		state["nested"]["value"] = -1
	_last_event = {"type": "fixture", "parameters": {"value": 1}}
	return {"ok": true, "state": state, "events": [_last_event]}
