extends RefCounted

const PEOPLE = preload("res://src/domain/gameplay/gameplay_people.gd")
const EVENTS = preload("res://src/domain/gameplay/gameplay_events.gd")
const CALENDAR = preload("res://src/domain/gameplay/gameplay_calendar.gd")


static func publish(state: Dictionary, pack: Dictionary) -> void:
	if (int(state.day) - 1) % int(pack.balance.CALENDAR.daysPerWeek) != pack.balance.CALENDAR.publicationDay:
		return
	if PEOPLE.busy(state, "van"):
		EVENTS.note(state, "src.gameplay.engine.lo_ky_phat_hanh_chua_co_nguoi_dieu_phoi_thay_van_trong_mock_nay")
		return
	var selected: Array = []
	var total := 0.0
	for article: Dictionary in state.articles:
		if article.published or not article.selected or selected.size() >= pack.balance.PUBLICATION.slots:
			continue
		article.published = true
		article.publishedDay = state.day
		selected.append(article.id)
		total += article.score
	var score: int = int(floor(total / selected.size() + 0.5)) if not selected.is_empty() else 0
	var tuning: Dictionary = pack.balance.PUBLICATION
	var gain: int = int(floor(float(score) / tuning.reputationScale + 0.5)) if not selected.is_empty() else -int(tuning.emptyLoss)
	state.reputation = maxf(0.0, state.reputation + gain)
	for article: Dictionary in state.articles:
		if article.id in selected and article.branch == "khue":
			state.pressure += tuning.pressure
	var week := CALENDAR.week(int(state.day), pack.balance.CALENDAR)
	state.reports.append({"day": state.day, "week": week, "score": score, "ids": selected, "reputation": state.reputation})
	EVENTS.note(state, "src.gameplay.engine.phat_hanh_so_value0_value1_bai_suc_hut_value2", {
		"value0": week, "value1": selected.size(), "value2": {"number": score, "format": "vi_integer"}})
	if week % int(tuning.grantFrequency) == 0:
		state.grants += tuning.baseGrants + (1 if score >= tuning.grantThreshold else 0)
		EVENTS.note(state, "src.gameplay.engine.nhan_suat_ho_tro_clb_dang_co_value0_suat_mock", {"value0": state.grants})
