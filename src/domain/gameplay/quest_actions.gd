extends RefCounted

const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")


static func apply(state: Dictionary, action: Dictionary, pack: Dictionary) -> Dictionary:
	if state.phase not in ["club", "investigation"]:
		return EVENTS.reject("hay_vao_buoi_clb_hoac_chon_dieu_tra_ngoai_gio")
	var quest := EVENTS.find(state.quests, str(action.get("id", "")))
	var tuning: Dictionary = pack.balance.RESEARCH
	var step: Dictionary = {}
	if action.type == "quest":
		if quest.is_empty() or quest.written:
			return EVENTS.reject("quest_khong_kha_dung")
		for candidate: Dictionary in pack.quest_steps:
			if candidate.id == action.get("step"):
				step = candidate
		if step.is_empty() or step.id in quest.steps:
			return EVENTS.reject("buoc_dieu_tra_khong_kha_dung")
	elif quest.is_empty() or quest.written or quest.steps.size() != pack.quest_steps.size():
		return EVENTS.reject("can_du_bon_buoc_va_phan_hoi_chinh_thuc")
	if state.energy < tuning.stepCost:
		return EVENTS.reject("khong_du_energy")
	state.energy -= tuning.stepCost
	state.metrics.energySpent += tuning.stepCost
	if action.type == "quest":
		var khue := PEOPLE.person(state, "khue")
		quest.steps.append(step.id)
		var fit := PEOPLE.effective_stat(state, khue, step.id, pack.balance.FATIGUE)
		quest.quality.append(minf(1.0, (fit + (tuning.toolBonus if step.id in khue.tools else 0.0)) / tuning.questDifficulty))
		khue.stats[step.id] += tuning.stepGrowth
		khue.fatigue += tuning.stepFatigue
		EVENTS.note(state, "journal.quest_step", {"title": EVENTS.title(quest), "step": EVENTS.text_ref(step.name_key)})
	else:
		quest.written = true
		var quality := 0.0
		for value: float in quest.quality:
			quality += value
		state.drafts.append({"id": quest.id, "title_key": quest.title_key, "title_parameters": quest.title_parameters,
			"branch": "khue", "author": "khue", "quality": quality / pack.quest_steps.size(),
			"attraction": tuning.questAttraction, "readyDay": state.day})
		EVENTS.note(state, "src.gameplay.engine.khue_chap_but_bai_vao_hang_doi_doi_soan")
	return {"ok": true}
