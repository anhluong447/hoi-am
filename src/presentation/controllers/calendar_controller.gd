extends RefCounted

var _session: RefCounted
var _text: RefCounted
var _pack: Dictionary
var _ui: Dictionary


func _init(session: RefCounted, text: RefCounted, pack: Dictionary, ui: Dictionary) -> void:
	_session = session
	_text = text
	_pack = pack.duplicate(true)
	_ui = ui.duplicate(true)


func model() -> Dictionary:
	var state: Dictionary = _session.snapshot()
	var weekdays: Array = _ui.weekday_keys
	var phase_key := ""
	for definition: Dictionary in _pack.phases:
		if definition.id == state.phase:
			phase_key = definition.name_key
	return {"date": _text.text("migration.hud.date", {"weekday": _text.text(weekdays[(int(state.day) - 1) % weekdays.size()]), "day": state.day}),
		"phase": _text.text(phase_key), "energy": _text.text("migration.hud.energy", {"energy": state.energy}),
		"money": _text.text("migration.hud.money", {"money": {"number": state.money, "format": "vi_integer"}}),
		"location": _text.text("content.gameplay.presentation.clb_hoi_am"),
		"objective_title": _text.text("migration.hud.objective_title"),
		"objective": _text.text("migration.hud.calendar_objective"),
		"controls": _text.text("migration.hud.calendar_controls"), "menu": _text.text("migration.ui.back"),
		"ended": state.ended}


func execute(command: Dictionary) -> Dictionary:
	var result: Dictionary = _session.execute(command)
	if not result.ok:
		return {"ok": false, "message": _text.text(result.error.text_key, result.error.get("parameters", {}))}
	var events: Array = result.events
	var message := ""
	if not events.is_empty():
		message = _text.text(events[-1].textKey, events[-1].params)
	return {"ok": true, "message": message}
