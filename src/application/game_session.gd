class_name GameSession
extends RefCounted
## Owns one ruleset. Callbacks are injected by composition, not discovered globally.

var _transition: Callable
var _validator: Callable
var _state: Dictionary = {}
var _initialized := false


func _init(transition: Callable, validator: Callable) -> void:
	_transition = transition
	_validator = validator


func is_ready() -> bool:
	return _initialized


func snapshot() -> Dictionary:
	return _state.duplicate(true)


func replace(candidate: Dictionary) -> Dictionary:
	if not _validator.is_valid():
		return _reject("missing_state_validator")
	var owned_candidate := candidate.duplicate(true)
	var validation: Variant = _validator.call(owned_candidate.duplicate(true))
	if not validation is Dictionary or typeof(validation.get("ok")) != TYPE_BOOL:
		return _reject("invalid_validation_result")
	if not validation["ok"]:
		return validation.duplicate(true)
	_state = owned_candidate
	_initialized = true
	return {"ok": true, "state": snapshot()}


func execute(command: Dictionary) -> Dictionary:
	if not _initialized:
		return _reject("session_not_initialized")
	if not _transition.is_valid():
		return _reject("missing_transition")
	var result: Variant = _transition.call(snapshot(), command.duplicate(true))
	if not result is Dictionary or typeof(result.get("ok")) != TYPE_BOOL:
		return _reject("invalid_transition_result")
	if not result.get("ok", false):
		return result.duplicate(true)
	if not result.get("state") is Dictionary:
		return _reject("invalid_transition_state")
	if not result.get("events", []) is Array:
		return _reject("invalid_transition_events")
	var replacement := replace(result["state"])
	if not replacement["ok"]:
		return replacement
	return {"ok": true, "state": snapshot(), "events": result.get("events", []).duplicate(true)}


func _reject(code: String) -> Dictionary:
	return {"ok": false, "error": {"code": code}}
