extends RefCounted

const RULES_ERROR_PREFIX = "src.core.game."
const MATH = preload("res://src/domain/formula_sandbox/formula_math.gd")
const CALENDAR = preload("res://src/domain/formula_sandbox/formula_calendar.gd")


static func apply(state: Dictionary, patch: Variant) -> Dictionary:
	if not patch is Dictionary:
		return _reject("value0_phai_la_so_khong_am", {"value0": "patch"})
	for key: String in ["reputation", "maxReputation", "pressure", "evidence", "difficultyOffset", "energy", "zeroRepStreak"]:
		if not patch.has(key):
			continue
		var value: Variant = patch[key]
		if not _number(value):
			return _reject("value0_phai_la_so_khong_am", {"value0": key})
		var maximum: float = 100.0 if key in ["reputation", "maxReputation"] else state.config.maxDifficultyOffset if key == "difficultyOffset" else state.config.dailyEnergy if key == "energy" else INF
		if value > maximum or (key in ["difficultyOffset", "energy", "zeroRepStreak"] and value != floorf(value)):
			return _reject("value0_nam_ngoai_pham_vi", {"value0": key})
		state[key] = value
	if patch.has("suspendedNextWeek"):
		if not patch.suspendedNextWeek is bool:
			return _reject("co_dinh_ban_phai_la_boolean")
		state.suspendedNextWeek = patch.suspendedNextWeek
	if patch.has("fatigue"):
		if not patch.fatigue is Dictionary:
			return _reject("met_phai_nam_trong_0_100_va_co_nhan_su_tuong_ung")
		for id: String in patch.fatigue:
			var value: Variant = patch.fatigue[id]
			if not state.fatigue.has(id) or not _number(value) or value > 100:
				return _reject("met_phai_nam_trong_0_100_va_co_nhan_su_tuong_ung")
			state.fatigue[id] = value
	if patch.has("joinWeek"):
		if not patch.joinWeek is Dictionary:
			return _reject("tuan_gia_nhap_phai_nam_trong_1_12")
		for id: String in patch.joinWeek:
			var matches: Array = state.staff.filter(func(p: Dictionary) -> bool: return p.id == id)
			var value: Variant = patch.joinWeek[id]
			if matches.is_empty() or not _number(value) or value != floorf(value) or value < 1 or value > 12:
				return _reject("tuan_gia_nhap_phai_nam_trong_1_12")
			matches[0].joinWeek = value
	state.maxReputation = maxf(state.maxReputation, state.reputation)
	state.outcome = MATH.outcome(state)
	CALENDAR.note(state, "debug", "src.core.game.chinh_trang_thai_sandbox", {}, patch)
	return {"ok": true}


static func _number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(value) and value >= 0


static func _reject(key: String, params: Dictionary = {}) -> Dictionary:
	return {"ok": false, "error": {"code": key, "text_key": RULES_ERROR_PREFIX + key, "parameters": params}}
