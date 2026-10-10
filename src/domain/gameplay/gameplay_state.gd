extends RefCounted

const CONFIG = preload("res://src/domain/gameplay/gameplay_config.gd")
const CALENDAR = preload("res://src/domain/gameplay/gameplay_calendar.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")


static func create(pack: Dictionary, overrides: Dictionary = {}) -> Dictionary:
	var config: Dictionary = pack.balance.DEFAULTS.duplicate(true)
	config.merge(overrides, true)
	var checked := CONFIG.validate(config, pack.balance)
	if not checked.ok:
		return checked
	var people: Array = []
	for definition: Dictionary in pack.roster:
		var candidate := definition.duplicate(true)
		candidate.merge({"fatigue": 0, "bond": 0, "events": 0, "romance": false,
			"weekendSkill": false, "tools": [], "skills": []})
		people.append(candidate)
	var state := {"version": 3, "config": config, "day": 1, "phase": "morning", "energy": 0,
		"money": pack.balance.PERSONAL.initialMoney, "reputation": 0, "pressure": 0, "grants": 0,
		"people": people, "cases": [], "quests": [], "drafts": [], "articles": [], "reports": [],
		"messages": [], "log": [], "sleepPrepared": false, "ended": false, "betrayal": false,
		"metrics": {"opened": 0, "assigned": 0, "restarts": 0, "approvals": 0, "energySpent": 0,
			"unusedEnergy": 0, "hangouts": 0, "jobs": 0}}
	add_week(state, pack)
	EVENTS.note(state, "src.gameplay.engine.bat_dau_lat_cat_co_che_nhi_duoc_mo_som_de_thu_phan_cong_noi_dung")
	return {"ok": true, "state": state}


static func add_week(state: Dictionary, pack: Dictionary) -> void:
	var week := CALENDAR.week(int(state.day), pack.balance.CALENDAR)
	for definition: Dictionary in pack.cases:
		var item := definition.duplicate(true)
		item.merge({"id": "W%d-%s" % [week, definition.key], "week": week,
			"expires": mini(int(state.config.days), int(state.day + pack.balance.RESEARCH.lifetime)),
			"opened": false, "status": "available", "owner": null, "progress": 0, "attempts": 0, "quality": 0})
		state.cases.append(item)
	state.quests.append({"id": "Q%d" % week, "title_key": pack.quest_title_key,
		"title_parameters": {"value0": week}, "steps": [], "quality": [], "written": false})
