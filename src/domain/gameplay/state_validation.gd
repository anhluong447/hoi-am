extends RefCounted

const NUMBERS = preload("res://src/domain/gameplay/gameplay_config.gd")
const RECORDS = preload("res://src/domain/gameplay/record_validation.gd")

var _pack: Dictionary
var _catalog: Dictionary


func _init(pack: Dictionary, catalog: Dictionary) -> void:
	_pack = pack.duplicate(true)
	_catalog = catalog.duplicate(true)


func validate(state: Dictionary) -> Dictionary:
	if state.get("version") != 3 or not _json_value(state):
		return _invalid("version_or_serializable")
	if not state.get("config") is Dictionary or not NUMBERS.validate(state.config, _pack.balance).ok:
		return _invalid("config")
	var phases: Array = _pack.phases.map(func(p: Dictionary) -> String: return p.id)
	if not NUMBERS.integer(state.get("day"), 1, state.config.days) or state.get("phase") not in phases:
		return _invalid("calendar")
	for key: String in ["energy", "money", "reputation", "pressure", "grants"]:
		if not NUMBERS.number(state.get(key)):
			return _invalid(key)
	if not NUMBERS.integer(state.grants):
		return _invalid("grants")
	for key: String in ["ended", "betrayal", "sleepPrepared"]:
		if typeof(state.get(key)) != TYPE_BOOL:
			return _invalid(key)
	if state.has("boostToday") and typeof(state.boostToday) != TYPE_BOOL:
		return _invalid("boostToday")
	if state.ended and state.day != state.config.days:
		return _invalid("ended")
	if state.phase == "investigation" and state.get("investigationFrom") not in ["personal", "evening", "weekend1", "weekend2"]:
		return _invalid("investigationFrom")
	for key: String in ["people", "cases", "quests", "drafts", "articles", "reports", "messages", "log"]:
		if not state.get(key) is Array:
			return _invalid(key)
		for record: Variant in state[key]:
			if not record is Dictionary:
				return _invalid(key)
	if not RECORDS.people(state, _pack) or not RECORDS.work(state, _pack):
		return _invalid("records")
	for event: Dictionary in state.log:
		if not NUMBERS.integer(event.get("day"), 1, state.config.days) or event.get("phase") not in phases:
			return _invalid("log_calendar")
		if event.has("textKey"):
			if not _catalog.has(event.textKey) or not event.get("params") is Dictionary or not _parameters(event.textKey, event.params):
				return _invalid("log_text")
		elif not event.get("message") is String:
			return _invalid("legacy_log")
	if not state.get("metrics") is Dictionary:
		return _invalid("metrics")
	for key: String in ["opened", "assigned", "restarts", "approvals", "energySpent", "unusedEnergy", "hangouts", "jobs"]:
		if not NUMBERS.number(state.metrics.get(key)):
			return _invalid("metric_" + key)
	if not _references(state):
		return _invalid("text_reference")
	return {"ok": true}


func _parameters(key: String, parameters: Dictionary) -> bool:
	var matcher := RegEx.new()
	matcher.compile("\\{([a-zA-Z][a-zA-Z0-9_]*)\\}")
	for token: RegExMatch in matcher.search_all(_catalog[key]):
		if not parameters.has(token.get_string(1)):
			return false
	return true


func _references(value: Variant) -> bool:
	if value is Dictionary:
		for key: String in value:
			if key.ends_with("_key") and not _catalog.has(value[key]):
				return false
			if not _references(value[key]):
				return false
		if value.has("text_key") and (not value.get("parameters") is Dictionary or not _parameters(value.text_key, value.parameters)):
			return false
		if value.has("title_key") and not _parameters(value.title_key, value.get("title_parameters", {})):
			return false
	elif value is Array:
		for item: Variant in value:
			if not _references(item):
				return false
	return true


static func _json_value(value: Variant, depth: int = 0) -> bool:
	if depth > 64:
		return false
	if value is Dictionary:
		for key: Variant in value:
			if (not key is String and not key is StringName) or not _json_value(value[key], depth + 1):
				return false
		return true
	if value is Array:
		for item: Variant in value:
			if not _json_value(item, depth + 1):
				return false
		return true
	return value == null or typeof(value) in [TYPE_BOOL, TYPE_STRING] or NUMBERS.number(value, -INF)


static func _invalid(field: String) -> Dictionary:
	return {"ok": false, "error": {"code": "invalid_gameplay_state", "text_key": "save.invalid", "field": field}}
