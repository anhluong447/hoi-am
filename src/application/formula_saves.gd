extends RefCounted

var _session: RefCounted
var _read: Callable
var _write: Callable


func _init(session: RefCounted, read: Callable, write: Callable) -> void:
	_session = session
	_read = read
	_write = write


func save(slot: String) -> Dictionary:
	return _write.call(slot, {"kind": "hoi-am-save", "envelope_version": 1, "content_version": 1,
		"ruleset": "formula_sandbox", "state": _session.snapshot()})


func load_slot(slot: String) -> Dictionary:
	var read: Dictionary = _read.call(slot)
	if not read.ok:
		return read
	var p: Dictionary = read.payload
	if p.get("kind") != "hoi-am-save" or p.get("envelope_version") != 1 or p.get("content_version") != 1 or p.get("ruleset") != "formula_sandbox" or not p.get("state") is Dictionary:
		return {"ok": false, "error": {"code": "wrong_ruleset", "text_key": "save.invalid"}}
	return _session.replace(p.state)
