extends RefCounted

const STATE = preload("res://src/domain/gameplay/gameplay_state.gd")
const CALENDAR = preload("res://src/domain/gameplay/gameplay_calendar.gd")
const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")
const RESEARCH = preload("res://src/domain/gameplay/research_actions.gd")
const NIGHT = preload("res://src/domain/gameplay/nightly_work.gd")
const PUBLICATION = preload("res://src/domain/gameplay/publication.gd")
const QUEST = preload("res://src/domain/gameplay/quest_actions.gd")
const PERSONAL = preload("res://src/domain/gameplay/personal_actions.gd")

var _pack: Dictionary


func _init(pack: Dictionary) -> void:
	_pack = pack.duplicate(true)


func create_session(overrides: Dictionary = {}) -> Dictionary:
	return STATE.create(_pack, overrides)


func transition(input_state: Dictionary, command: Dictionary) -> Dictionary:
	var state := input_state.duplicate(true)
	if state.ended:
		return EVENTS.reject("luot_thu_da_ket_thuc_hay_tao_luot_moi")
	var start: int = state.log.size()
	var type: Variant = command.get("type")
	var outcome := {"ok": true}
	match type:
		"school":
			if state.phase != "morning":
				return EVENTS.reject("khong_phai_buoi_sang_di_hoc")
			state.phase = "club"
			state.energy = state.config.clubEnergy
			EVENTS.note(state, "src.gameplay.engine.tan_hoc_bat_dau_2_gio_clb")
		"endClub", "finishInvestigation":
			var expected := "club" if type == "endClub" else "investigation"
			if state.phase != expected:
				return EVENTS.reject("khong_phai_buoi_clb" if type == "endClub" else "khong_dang_dieu_tra_ngoai_gio")
			state.metrics.unusedEnergy += state.energy
			state.energy = 0
			if type == "endClub":
				state.phase = "personal"
			else:
				CALENDAR.consume_slot(state)
		"activity":
			outcome = PERSONAL.apply(state, command, _pack)
		"sleep":
			outcome = _sleep(state)
		"open", "assign", "approve":
			outcome = RESEARCH.apply(state, command, _pack)
		"select":
			if state.sleepPrepared:
				return EVENTS.reject("da_chot_so_bao_khi_len_giuong")
			var article := EVENTS.find(state.articles, str(command.get("id", "")))
			if article.is_empty() or article.published:
				return EVENTS.reject("bai_khong_kha_dung")
			article.selected = not article.selected
		"quest", "write":
			outcome = QUEST.apply(state, command, _pack)
		"date", "gift", "tool", "boost", "upgrade":
			outcome = PERSONAL.apply(state, command, _pack)
		_:
			return EVENTS.reject("lenh_khong_hop_le")
	if not outcome.ok:
		return outcome
	return {"ok": true, "state": state, "events": state.log.slice(start).duplicate(true)}


func _sleep(state: Dictionary) -> Dictionary:
	if state.phase != "bed":
		return EVENTS.reject("hay_hoan_thanh_cac_slot_trong_ngay_truoc_khi_ngu")
	if not state.sleepPrepared:
		NIGHT.process(state, _pack)
		PUBLICATION.publish(state, _pack)
		state.sleepPrepared = true
		var partners: Array = state.people.filter(func(p: Dictionary) -> bool: return p.romance)
		if not state.betrayal and partners.size() > 1:
			state.betrayal = true
			for candidate: Dictionary in partners:
				candidate.bond = maxf(0.0, candidate.bond - _pack.balance.PERSONAL.betrayalBondLoss)
			EVENTS.note(state, "src.gameplay.engine.bi_phat_hien_bat_ca_hai_tay_cac_ban_gai_giam_bond_va_hieu_suat_t")
	for message: Dictionary in state.messages:
		if not message.resolved:
			EVENTS.note(state, "src.gameplay.engine.con_tin_nhan_dong_doi_can_duyet_ngay_truoc_khi_ngu")
			return {"ok": true}
	for candidate: Dictionary in state.people:
		candidate.fatigue = maxf(0.0, minf(_pack.balance.FATIGUE.cap, candidate.fatigue) - state.config.recovery)
	if state.day == state.config.days:
		state.ended = true
		EVENTS.note(state, "src.gameplay.engine.ket_thuc_lat_cat_ket_qua_la_chi_bao_co_che_mock")
		return {"ok": true}
	state.day += 1
	state.sleepPrepared = false
	state.boostToday = false
	state.phase = "weekend1" if CALENDAR.weekend(int(state.day), _pack.balance.CALENDAR) else "morning"
	state.energy = 0
	for item: Dictionary in state.cases:
		if state.day > item.expires and item.status in ["available", "working", "blocked"]:
			item.status = "expired"
			for message: Dictionary in state.messages:
				if message.caseId == item.id:
					message.resolved = true
	if (int(state.day) - 1) % int(_pack.balance.CALENDAR.daysPerWeek) == 0:
		STATE.add_week(state, _pack)
	return {"ok": true}
