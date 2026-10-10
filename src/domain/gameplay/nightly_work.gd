extends RefCounted

const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")
const CALENDAR = preload("res://src/domain/gameplay/gameplay_calendar.gd")
const RESEARCH = preload("res://src/domain/gameplay/research_actions.gd")


static func process(state: Dictionary, pack: Dictionary) -> void:
	var weekend := CALENDAR.weekend(int(state.day), pack.balance.CALENDAR)
	var tuning: Dictionary = pack.balance.RESEARCH
	for item: Dictionary in state.cases:
		if item.status != "working":
			continue
		var candidate := PEOPLE.person(state, item.owner)
		if weekend and not candidate.weekendSkill:
			continue
		item.progress += 1
		candidate.fatigue += state.config.fatiguePerWork
		var fit := PEOPLE.effective_stat(state, candidate, item.need, pack.balance.FATIGUE)
		fit += tuning.toolBonus if item.need in candidate.tools else 0.0
		fit += tuning.synergyBonus if "synergy" in candidate.skills else 0.0
		if item.progress == 1 and fit < item.difficulty:
			item.status = "blocked"
			EVENTS.feedback(state, item, "mismatch")
			EVENTS.note(state, "src.gameplay.engine.value0_bao_khong_phu_hop_value1", {
				"value0": EVENTS.text_ref(candidate.name_key), "value1": EVENTS.title(item)})
			continue
		item.quality = minf(1.0, fit / tuning.statScale)
		if item.progress >= state.config.researchDays:
			RESEARCH.queue(state, item)
			EVENTS.feedback(state, item, "complete")
		else:
			EVENTS.feedback(state, item, "progress")
	var van := PEOPLE.person(state, "van")
	if (not weekend or van.weekendSkill) and not PEOPLE.busy(state, "van"):
		var capacity: int = int(state.config.editorialCapacity)
		for draft: Dictionary in state.drafts:
			if draft.readyDay >= state.day or draft.get("processed", false) or (int(state.day) - 1) % int(pack.balance.CALENDAR.daysPerWeek) == pack.balance.CALENDAR.publicationDay:
				continue
			if capacity == 0:
				break
			capacity -= 1
			draft.processed = true
			var multiplier: float = pack.balance.PUBLICATION.khueMultiplier if draft.branch == "khue" else 1.0
			var score := minf(pack.balance.PUBLICATION.maxScore, floor(pack.balance.PUBLICATION.maxScore * pow(draft.attraction / tuning.statScale, 2) * draft.quality * multiplier * (1.0 + state.config.packaging) + 0.5))
			var article := draft.duplicate(true)
			article.merge({"score": score, "selected": true, "published": false})
			state.articles.append(article)
			EVENTS.note(state, "src.gameplay.engine.van_hoan_tat_viet_bien_tap_value0", {"value0": EVENTS.title(draft)})
	else:
		for draft: Dictionary in state.drafts:
			if not draft.get("processed", false):
				EVENTS.note(state, "src.gameplay.engine.hang_doi_doi_soan_cho_van_dang_tac_nghiep_hoac_nghi_cuoi_tuan")
				break
