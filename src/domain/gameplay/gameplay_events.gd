extends RefCounted
## Structured references resolve only in presentation; no translated labels in rules.


static func reject(reason: String) -> Dictionary:
	return {"ok": false, "error": {"code": reason, "text_key": "src.gameplay.engine." + reason}}


static func note(state: Dictionary, key: String, parameters: Dictionary = {}) -> void:
	state.log.append({"day": state.day, "phase": state.phase, "textKey": key, "params": parameters})


static func text_ref(key: String, parameters: Dictionary = {}) -> Dictionary:
	return {"text_key": key, "parameters": parameters}


static func title(item: Dictionary) -> Dictionary:
	return text_ref(item.title_key, item.get("title_parameters", {}))


static func find(items: Array, id: String) -> Dictionary:
	for item: Dictionary in items:
		if item.id == id:
			return item
	return {}


static func feedback(state: Dictionary, item: Dictionary, kind: String) -> void:
	state.messages.append({"id": "%s-%d-%d" % [item.id, item.attempts, state.day], "caseId": item.id,
		"kind": kind, "resolved": false, "day": state.day})
