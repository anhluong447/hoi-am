extends RefCounted

const MATH = preload("res://src/domain/formula_sandbox/formula_math.gd")
const CALENDAR = preload("res://src/domain/formula_sandbox/formula_calendar.gd")
const DEBUG = preload("res://src/domain/formula_sandbox/formula_debug.gd")

var _pack: Dictionary


func _init(pack: Dictionary) -> void:
	_pack = pack.duplicate(true)


func create_session(solo: bool = false) -> Dictionary:
	var staff: Array = _pack.staff.filter(func(p: Dictionary) -> bool: return not solo or p.id == "khue").duplicate(true)
	var fatigue: Dictionary = {}
	# Source retains all fatigue keys even for its isolated one-person policy.
	for person: Dictionary in _pack.staff:
		fatigue[person.id] = 0
	return {"version": 2, "kind": "press-club-sandbox", "config": _pack.config.duplicate(true), "day": 1, "week": 1,
		"energy": _pack.config.dailyEnergy, "staff": staff, "fatigue": fatigue, "workedToday": [],
		"subjects": _pack.subjects.duplicate(true), "weekArticles": [], "selectedArticleIds": [],
		"reputation": _pack.config.initialReputation, "maxReputation": _pack.config.initialReputation,
		"pressure": 0, "evidence": 0, "difficultyOffset": 0, "suspendedNextWeek": false,
		"zeroRepStreak": 0, "reports": [], "journal": [], "outcome": null}


static func active_subjects(state: Dictionary) -> Array:
	return state.subjects.filter(func(s: Dictionary) -> bool: return not s.done and s.appears <= state.day and state.day <= s.expires)


static func active_staff(state: Dictionary) -> Array:
	return state.staff.filter(func(p: Dictionary) -> bool: return p.joinWeek <= state.week and p.id not in state.workedToday)


func transition(input: Dictionary, command: Dictionary) -> Dictionary:
	if input.outcome != null:
		return reject("hoc_ky_da_ket_thuc_hay_tao_luot_choi_moi")
	var state := input.duplicate(true)
	var start: int = state.journal.size()
	var result := _apply(state, command)
	if not result.ok:
		return result
	return {"ok": true, "state": state, "events": state.journal.slice(start).duplicate(true)}


static func reject(code: String, params: Dictionary = {}) -> Dictionary:
	return {"ok": false, "error": {"code": code, "text_key": "src.core.game." + code, "parameters": params}}


func _apply(state: Dictionary, command: Dictionary) -> Dictionary:
	var c: Dictionary = state.config
	var id := str(command.get("id", ""))
	match command.get("type"):
		"scout", "interview":
			var subject: Dictionary = {}
			for s: Dictionary in active_subjects(state):
				if s.id == id:
					subject = s
			if subject.is_empty():
				return reject("de_tai_chua_xuat_hien_het_han_hoac_da_lam")
			if command.type == "scout":
				if subject.scouted:
					return reject("de_tai_da_duoc_tham_do")
				if state.energy < c.scoutCost:
					return reject("khong_du_energy_de_tham_do")
				state.energy -= c.scoutCost
				subject.scouted = true
				CALENDAR.note(state, "scout", "src.core.game.tham_do_value0", {"value0": id}, {"attraction": subject.attraction, "pressure": subject.pressure, "energyCost": c.scoutCost})
			else:
				return _interview(state, subject, command)
		"edit":
			var grit: Variant = command.get("grit")
			if (typeof(grit) not in [TYPE_INT, TYPE_FLOAT]) or not is_finite(grit) or grit < 0 or grit > 1:
				return reject("gai_goc_phai_nam_trong_0_1")
			var a: Dictionary = {}
			for item: Dictionary in state.weekArticles:
				if item.id == id:
					a = item
			if a.is_empty():
				return reject("khong_tim_thay_bai")
			for subject: Dictionary in state.subjects:
				if subject.id == a.subjectId:
					a.grit = grit
					a.merge(MATH.article(subject, a.q, grit, c), true)
			CALENDAR.note(state, "edit", "src.core.game.bien_tap_value0_gai_goc_value1", {"value0": id, "value1": floorf(grit * 100 + 0.5)})
		"select":
			var ids: Variant = command.get("ids")
			if not ids is Array or ids.size() > c.slots:
				return reject("chon_toi_da_4_bai_thanh_cong_khong_trung_nhau")
			var seen: Array = []
			for value: Variant in ids:
				if value in seen or not state.weekArticles.any(func(a: Dictionary) -> bool: return a.id == value and a.score > 0):
					return reject("chon_toi_da_4_bai_thanh_cong_khong_trung_nhau")
				seen.append(value)
			state.selectedArticleIds = ids.duplicate()
		"next":
			CALENDAR.advance(state)
		"closeWeek":
			if int(state.day) % int(c.daysPerWeek) != 0:
				return reject("chi_phat_hanh_bao_vao_cuoi_tuan")
			CALENDAR.advance(state)
		"debug":
			return DEBUG.apply(state, command.get("patch"))
		_:
			return {"ok": false, "error": {"code": "unknown_command", "text_key": "error.invalid_command"}}
	return {"ok": true}


func _interview(state: Dictionary, subject: Dictionary, command: Dictionary) -> Dictionary:
	var reporter: Dictionary = {}
	var supporter: Dictionary = {}
	var rid: Variant = command.get("reporter")
	var sid: Variant = command.get("supporter")
	for p: Dictionary in state.staff:
		if p.id == rid and p.joinWeek <= state.week:
			reporter = p
		if p.id == sid and p.joinWeek <= state.week:
			supporter = p
	if reporter.is_empty() or (sid != null and supporter.is_empty()):
		return reject("nhan_su_chua_gia_nhap")
	for p: Dictionary in [reporter, supporter]:
		if not p.is_empty() and p.id in state.workedToday:
			return reject("value0_da_lam_viec_hom_nay", {"value0": {"text_key": p.name_key, "parameters": {}}})
	if rid == sid:
		return reject("phong_vien_va_ho_tro_phai_la_hai_nguoi_khac_nhau")
	if supporter.is_empty() and rid != "khue":
		return reject("chi_khue_co_the_tu_ho_tro")
	if supporter.is_empty() and active_staff(state).any(func(p: Dictionary) -> bool: return p.id != "khue"):
		return reject("con_nguoi_ho_tro_kha_dung_hay_phan_cong_mot_nguoi")
	if state.energy < subject.energy:
		return reject("khong_du_energy_cho_phong_van")
	var c: Dictionary = state.config
	var power := MATH.power(reporter, supporter, subject, state.fatigue, c)
	var tools := MATH.equipment(state.maxReputation, c)
	var q := MATH.quality(power, tools, subject.difficulty, state.difficultyOffset, c)
	state.energy -= subject.energy
	for p: Dictionary in [reporter, supporter]:
		if not p.is_empty():
			state.workedToday.append(p.id)
			state.fatigue[p.id] = minf(100, state.fatigue[p.id] + c.fatigueTask)
	subject.done = true
	var article := {"id": subject.id, "subjectId": subject.id, "reporterId": rid, "supporterId": sid, "day": state.day,
		"q": q, "power": power, "equipment": tools, "difficultyOffset": state.difficultyOffset, "grit": 0.5}
	article.merge(MATH.article(subject, q, 0.5, c))
	state.weekArticles.append(article)
	if state.selectedArticleIds.size() < c.slots and article.score > 0:
		state.selectedArticleIds.append(article.id)
	var details := article.duplicate(true)
	details.energyCost = subject.energy
	CALENDAR.note(state, "interview", "src.core.game.phong_van_value0_q_value1", {"value0": subject.id, "value1": "%.3f" % q}, details)
	return {"ok": true}
