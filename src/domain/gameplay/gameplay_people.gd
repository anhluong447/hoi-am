extends RefCounted


static func person(state: Dictionary, id: String) -> Dictionary:
	for candidate: Dictionary in state.people:
		if candidate.id == id:
			return candidate
	return {}


static func busy(state: Dictionary, id: String) -> bool:
	for item: Dictionary in state.cases:
		if item.owner == id and item.status in ["working", "blocked"]:
			return true
	return false


static func available(state: Dictionary, id: String) -> Dictionary:
	var candidate := person(state, id)
	if candidate.is_empty() or candidate.joinDay > state.day or id == "khue":
		return {"ok": false, "reason": "dong_doi_chua_kha_dung"}
	if busy(state, id):
		return {"ok": false, "reason": "dong_doi_dang_phu_trach_ho_so_khac"}
	return {"ok": true}


static func effective_stat(state: Dictionary, candidate: Dictionary, key: String, fatigue: Dictionary) -> float:
	var penalty: float = 1.0 - state.config.romancePenalty if state.betrayal and candidate.romance else 1.0
	return candidate.stats[key] * penalty * maxf(fatigue.minimumEfficiency, 1.0 - candidate.fatigue / fatigue.divisor)
