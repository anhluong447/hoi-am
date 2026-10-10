extends RefCounted
## Pure v1/v2 -> v3 field migration. Caller validates both shape and result.

const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")


static func migrate(candidate: Dictionary, pack: Dictionary) -> Dictionary:
	var version: Variant = candidate.get("version")
	if typeof(version) not in [TYPE_INT, TYPE_FLOAT] or (version != 1 and version != 2 and version != 3):
		return {"ok": false, "error": {"code": "unsupported_state_version", "text_key": "save.invalid"}}
	var state := candidate.duplicate(true)
	state.version = int(version)
	if state.version == 3:
		return {"ok": true, "state": state}
	for field: String in ["people", "cases", "quests", "drafts", "articles"]:
		if not state.get(field) is Array:
			return _invalid()
		for item: Variant in state[field]:
			if not item is Dictionary or not item.get("id") is String:
				return _invalid()
	for candidate_person: Dictionary in state.people:
		var definition := EVENTS.find(pack.roster, candidate_person.id)
		if definition.is_empty() or not candidate_person.get("name") is String or not candidate_person.get("skills") is Array:
			return _invalid()
		candidate_person.name_key = definition.name_key
		candidate_person.erase("name")
		if state.version == 1:
			for index: int in candidate_person.skills.size():
				var skill: Variant = candidate_person.skills[index]
				if not skill is String:
					return _invalid()
				candidate_person.skills[index] = pack.legacy_skills.get(skill, skill)
	for item: Dictionary in state.cases:
		var definition: Dictionary = {}
		for row: Dictionary in pack.cases:
			if row.key == item.get("key"):
				definition = row
		if definition.is_empty():
			return _invalid()
		for field: String in ["title", "story", "teaser"]:
			if not item.get(field) is String:
				return _invalid()
			item[field + "_key"] = definition[field + "_key"]
			item.erase(field)
	for item: Dictionary in state.quests + state.drafts + state.articles:
		if not item.get("title") is String:
			return _invalid()
		var case_item := EVENTS.find(state.cases, item.id)
		if not case_item.is_empty():
			item.title_key = case_item.title_key
		elif item.id.begins_with("Q") and item.id.substr(1).is_valid_int():
			item.title_key = pack.quest_title_key
			item.title_parameters = {"value0": int(item.id.substr(1))}
		else:
			return _invalid()
		item.erase("title")
	state.version = 3
	return {"ok": true, "state": state}


static func _invalid() -> Dictionary:
	return {"ok": false, "error": {"code": "invalid_legacy_state", "text_key": "save.invalid"}}
