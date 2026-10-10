extends Node

signal back_requested

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const RULES = preload("res://src/domain/formula_sandbox/formula_rules.gd")
const VALIDATOR = preload("res://src/domain/formula_sandbox/formula_validation.gd")
const POLICY = preload("res://src/domain/formula_sandbox/formula_policy.gd")
const SESSION = preload("res://src/application/game_session.gd")
const SAVES = preload("res://src/application/formula_saves.gd")
const STORE = preload("res://src/infrastructure/saves/file_save_store.gd")
const VIEW = preload("res://src/presentation/workspace/workspace_view.tscn")

var _setup: Dictionary
var _pack: Dictionary
var _rules: RefCounted
var _validator: RefCounted
var _session: RefCounted
var _store: RefCounted
var _saves: RefCounted
var _view: Control
var _results: Array = []
var _busy := false


func _ready() -> void:
	_setup = STARTUP.prepare()
	_pack = LOADER.read_dictionary("res://content/formula_sandbox/pack.json").data
	_rules = RULES.new(_pack)
	_validator = VALIDATOR.new(_pack, _setup.data.catalog)
	_session = SESSION.new(_rules.transition, _validator.validate)
	_session.replace(_rules.create_session())
	_store = STORE.new("user://saves/formula_sandbox")
	_saves = SAVES.new(_session, _store.read_slot, _store.write_slot)
	_view = VIEW.instantiate()
	_view.command_requested.connect(_command)
	_view.close_requested.connect(func() -> void: back_requested.emit())
	$Interface.add_child(_view)
	_render()


func _render() -> void:
	var rows: Array = _results.duplicate(true)
	var state: Dictionary = _session.snapshot()
	var parameters: Dictionary = {}
	for field: String in ["day", "week", "energy", "reputation", "pressure", "evidence"]:
		parameters[field] = snappedf(state[field], 0.01)
	rows.push_front({"text": _setup.text.text("sandbox.state", parameters)})
	rows.append({"text": _setup.text.text("sandbox.reset"), "command": {"type": "reset"}})
	rows.append({"text": _setup.text.text("sandbox.advance"), "command": {"type": "auto_day"}})
	for preset: Dictionary in LOADER.read_dictionary("res://content/formula_sandbox/debug_presets.json").data.presets:
		rows.append({"text": _setup.text.text(preset.text_key), "command": preset.command})
	for policy: Dictionary in _pack.policies:
		rows.append({"text": _setup.text.text("sandbox.run", {"name": _setup.text.text(policy.name_key)}), "command": {"type": "benchmark", "id": policy.id}})
	for action: String in ["save", "load"]:
		rows.append({"text": _setup.text.text("play." + action, {"slot": 1}), "command": {"type": action}})
	var model := {"title": _setup.text.text("sandbox.boot"), "tabs": [], "rows": rows, "message": "", "close": _setup.text.text("play.quit")}
	_view.configure(model, _setup.data.workspace, STARTUP.ui_resources(_setup.data)["Source Serif 4"])


func _command(command: Dictionary) -> void:
	if _busy:
		return
	if command.type in ["reset", "auto_day", "debug"]:
		var result: Dictionary
		if command.type == "reset":
			result = _session.replace(_rules.create_session())
			_results.clear()
		elif command.type == "auto_day":
			result = POLICY.run_day(_session, _pack.policies[0])
		else:
			result = _session.execute(command)
		if not result.ok:
			_results.append({"text": _setup.text.text(result.error.text_key, result.error.get("parameters", {}))})
		_render()
		return
	if command.type in ["save", "load"]:
		var result: Dictionary = _saves.save("slot_1") if command.type == "save" else _saves.load_slot("slot_1")
		var message: String = _setup.text.text("play.loaded") if command.type == "load" else _setup.text.text("play.saved", {"time": Time.get_datetime_string_from_system()})
		_results.append({"text": message if result.ok else _setup.text.text("save.invalid")})
		_render()
		return
	_busy = true
	var policy: Dictionary = _pack.policies.filter(func(p: Dictionary) -> bool: return p.id == command.id)[0]
	_session.replace(_rules.create_session(policy.get("solo", false)))
	for _day: int in 61:
		if _session.snapshot().outcome != null:
			break
		var result := POLICY.run_day(_session, policy)
		if not result.ok:
			_results.append({"text": _setup.text.text(result.error.text_key, result.error.get("parameters", {}))})
			break
		await get_tree().process_frame
		if not is_inside_tree():
			return
	var s: Dictionary = _session.snapshot()
	if s.outcome != null:
		_results.append({"text": _setup.text.text("sandbox.result", {"name": _setup.text.text(policy.name_key), "outcome": _setup.text.text("sandbox." + s.outcome), "evidence": snappedf(s.evidence, 0.01), "reputation": snappedf(s.reputation, 0.01)})})
	_busy = false
	_render()
