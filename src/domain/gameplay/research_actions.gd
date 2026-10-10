extends RefCounted
## Only case opening/assignment and feedback needed by the first calendar slice.

const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")
const CALENDAR = preload("res://src/domain/gameplay/gameplay_calendar.gd")


static func apply(state: Dictionary, action: Dictionary, pack: Dictionary) -> Dictionary:
	var type: String = action.get("type", "")
	var item := EVENTS.find(state.cases, str(action.get("id", "")))
	if type == "open":
		if state.phase not in ["club", "investigation"]:
			return EVENTS.reject("hay_vao_buoi_clb_hoac_chon_dieu_tra_ngoai_gio")
		if item.is_empty() or item.status != "available" or item.opened or state.day > item.expires:
			return EVENTS.reject("ho_so_khong_the_mo")
		if state.energy < state.config.openCost:
			return EVENTS.reject("khong_du_energy")
		state.energy -= state.config.openCost
		state.metrics.energySpent += state.config.openCost
		item.opened = true
		state.metrics.opened += 1
		EVENTS.note(state, "src.gameplay.engine.phong_van_mo_ho_so_value0", {"value0": EVENTS.title(item)})
	elif type == "assign":
		if state.phase != "club" or CALENDAR.weekend(int(state.day), pack.balance.CALENDAR):
			return EVENTS.reject("chi_giao_viec_moi_trong_buoi_clb_ngay_di_hoc")
		if item.is_empty() or not item.opened or item.status != "available" or state.day > item.expires:
			return EVENTS.reject("hay_phong_van_mo_ho_so_truoc")
		var id: String = str(action.get("person", ""))
		var availability := PEOPLE.available(state, id)
		if not availability.ok:
			return EVENTS.reject(availability.reason)
		if state.energy < state.config.assignCost:
			return EVENTS.reject("khong_du_energy")
		state.energy -= state.config.assignCost
		state.metrics.energySpent += state.config.assignCost
		item.owner = id
		item.status = "working"
		item.progress = 0
		item.attempts += 1
		state.metrics.assigned += 1
		EVENTS.note(state, "journal.assignment", {"title": EVENTS.title(item),
			"name": EVENTS.text_ref(PEOPLE.person(state, id).name_key)})
	elif type == "approve":
		return approve(state, action)
	return {"ok": true}


static func approve(state: Dictionary, action: Dictionary) -> Dictionary:
	if state.phase != "bed" or not state.sleepPrepared:
		return EVENTS.reject("duyet_tin_nhan_khi_len_giuong")
	var message := EVENTS.find(state.messages, str(action.get("id", "")))
	if message.is_empty() or message.resolved:
		return EVENTS.reject("tin_nhan_da_xu_ly")
	var item := EVENTS.find(state.cases, message.caseId)
	var option: String = str(action.get("option", ""))
	if option == "reassign":
		if item.is_empty() or item.status not in ["working", "blocked"]:
			return EVENTS.reject("ho_so_khong_the_doi_nguoi")
		var id: String = str(action.get("person", ""))
		if id == item.owner:
			return EVENTS.reject("hay_chon_mot_nguoi_khac")
		var checked := PEOPLE.available(state, id)
		if not checked.ok:
			return EVENTS.reject(checked.reason)
		item.owner = id
		item.status = "working"
		item.progress = 0
		item.quality = 0
		item.attempts += 1
		state.metrics.restarts += 1
	elif option == "cancel":
		if item.is_empty():
			return EVENTS.reject("khong_co_ho_so")
		item.status = "cancelled"
	elif option == "short":
		if item.is_empty() or message.kind == "complete":
			return EVENTS.reject("khong_the_rut_gon_ho_so")
		item.quality = minf(0.5, item.quality if item.quality else 0.3)
		queue(state, item)
	elif option != "continue" or message.kind == "mismatch":
		return EVENTS.reject("ho_so_khong_phu_hop_can_doi_nguoi_rut_gon_hoac_huy")
	message.resolved = true
	state.metrics.approvals += 1
	EVENTS.note(state, "src.gameplay.engine.duyet_value0_value1_0_energy", {"value0": EVENTS.title(item), "value1": option})
	return {"ok": true}


static func queue(state: Dictionary, item: Dictionary) -> void:
	state.drafts.append({"id": item.id, "title_key": item.title_key, "branch": "team", "author": item.owner,
		"quality": item.quality, "attraction": item.attraction, "readyDay": state.day})
	item.status = "draft"
