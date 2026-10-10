extends RefCounted
const DATA = preload("res://src/shared/json_data.gd")
const CONFIG = preload("res://src/domain/formula_sandbox/formula_config.gd")

var _pack: Dictionary
var _catalog: Dictionary


func _init(pack: Dictionary, catalog: Dictionary) -> void:
	_pack = pack.duplicate(true)
	_catalog = catalog.duplicate(true)


func validate(s: Dictionary) -> Dictionary:
	if not _json(s) or not _shape(s):
		return _invalid()
	return {"ok": true}


func _shape(s: Dictionary) -> bool:
	var fields := ["version", "kind", "config", "day", "week", "energy", "staff", "fatigue", "workedToday", "subjects", "weekArticles", "selectedArticleIds", "reputation", "maxReputation", "pressure", "evidence", "difficultyOffset", "suspendedNextWeek", "zeroRepStreak", "reports", "journal", "outcome"]
	for field: String in fields:
		if not s.has(field):
			return false
	if s.size() != fields.size() or s.version != 2 or s.kind != "press-club-sandbox" or not CONFIG.validate(s.config, _pack.config):
		return false
	for field: String in ["day", "week", "energy", "difficultyOffset", "zeroRepStreak"]:
		if not _number(s[field]) or s[field] != floorf(s[field]):
			return false
	if s.day < 1 or s.day > 61 or s.week != minf(12, floorf((s.day - 1) / 5.0) + 1) or s.energy > s.config.dailyEnergy or s.difficultyOffset > s.config.maxDifficultyOffset:
		return false
	for field: String in ["reputation", "maxReputation", "pressure", "evidence"]:
		if not _number(s[field]):
			return false
	if s.reputation > 100 or s.maxReputation > 100 or s.maxReputation < s.reputation or not s.suspendedNextWeek is bool:
		return false
	if s.outcome != null and s.outcome not in ["win", "bitter", "defeat", "disbanded"]:
		return false
	for field: String in ["staff", "workedToday", "subjects", "weekArticles", "selectedArticleIds", "reports", "journal"]:
		if not s[field] is Array:
			return false
	if not s.fatigue is Dictionary or s.fatigue.size() != _pack.staff.size() or s.staff.is_empty():
		return false
	var staff_ids: Array = []
	for person: Variant in s.staff:
		if not person is Dictionary or not person.has_all(["id", "name_key", "stats", "joinWeek"]) or person.id in staff_ids:
			return false
		var definitions: Array = _pack.staff.filter(func(p: Dictionary) -> bool: return p.id == person.id)
		var original: Dictionary = person.duplicate(true)
		if definitions.is_empty() or not _number(person.joinWeek) or person.joinWeek < 1 or person.joinWeek > 12 or person.joinWeek != floorf(person.joinWeek):
			return false
		original.joinWeek = definitions[0].joinWeek
		if not DATA.equivalent(original, definitions[0]):
			return false
		staff_ids.append(person.id)
	for p: Dictionary in _pack.staff:
		if not s.fatigue.has(p.id) or not _number(s.fatigue[p.id]) or s.fatigue[p.id] > 100:
			return false
	var worked: Array = []
	for id: Variant in s.workedToday:
		if id not in staff_ids or id in worked:
			return false
		worked.append(id)
	if s.subjects.size() != _pack.subjects.size():
		return false
	for index: int in s.subjects.size():
		var subject: Variant = s.subjects[index]
		if not subject is Dictionary or not subject.has_all(["scouted", "done"]) or not subject.scouted is bool or not subject.done is bool:
			return false
		var copy: Dictionary = subject.duplicate(true)
		copy.scouted = false
		copy.done = false
		if not DATA.equivalent(copy, _pack.subjects[index]):
			return false
	var article_ids: Array = []
	for a: Variant in s.weekArticles:
		if not _article(a, staff_ids) or a.id in article_ids:
			return false
		article_ids.append(a.id)
	var selected: Array = []
	for id: Variant in s.selectedArticleIds:
		if id not in article_ids or id in selected:
			return false
		selected.append(id)
	if selected.size() > s.config.slots:
		return false
	for report: Variant in s.reports:
		if not report is Dictionary or not report.has_all(["week", "day", "articles", "selectedIds", "label_key", "score", "strike"]):
			return false
		if not _catalog.has(report.label_key) or not _number(report.score) or not report.articles is Array:
			return false
		for a: Variant in report.articles:
			if not _article(a, staff_ids):
				return false
	for event: Variant in s.journal:
		if not event is Dictionary or not event.has_all(["day", "week", "type", "text_key", "params", "details"]) or not _catalog.has(event.text_key) or not event.params is Dictionary or not event.details is Dictionary:
			return false
	return true


func _article(a: Variant, staff: Array) -> bool:
	if not a is Dictionary or not a.has_all(["id", "subjectId", "reporterId", "supporterId", "day", "q", "power", "equipment", "difficultyOffset", "grit", "score", "pressure", "evidence"]):
		return false
	if a.id != a.subjectId or not _pack.subjects.any(func(s: Dictionary) -> bool: return s.id == a.subjectId) or a.reporterId not in staff or (a.supporterId != null and a.supporterId not in staff):
		return false
	for field: String in ["day", "q", "power", "equipment", "difficultyOffset", "grit", "score", "pressure", "evidence"]:
		if not _number(a[field]):
			return false
	return a.grit <= 1 and a.q <= _pack.config.qualityCap and a.score <= _pack.config.maxScore


static func _number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(value) and value >= 0


static func _json(value: Variant, depth: int = 0) -> bool:
	if depth > 64:
		return false
	if value is Dictionary:
		for key: Variant in value:
			if typeof(key) not in [TYPE_STRING, TYPE_STRING_NAME] or not _json(value[key], depth + 1):
				return false
	elif value is Array:
		for item: Variant in value:
			if not _json(item, depth + 1):
				return false
	elif typeof(value) not in [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING] or (value is float and not is_finite(value)):
		return false
	return true


static func _invalid() -> Dictionary:
	return {"ok": false, "error": {"code": "invalid_formula_state", "text_key": "save.invalid"}}
