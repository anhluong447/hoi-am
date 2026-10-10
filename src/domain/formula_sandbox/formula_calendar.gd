extends RefCounted

const MATH = preload("res://src/domain/formula_sandbox/formula_math.gd")


static func note(state: Dictionary, type: String, key: String, params: Dictionary = {}, details: Dictionary = {}) -> void:
	state.journal.append({"day": state.day, "week": state.week, "type": type, "text_key": key, "params": params, "details": details.duplicate(true)})


static func advance(state: Dictionary) -> void:
	var c: Dictionary = state.config
	if int(state.day) % int(c.daysPerWeek) == 0:
		var report := MATH.preview(state)
		report.merge({"week": state.week, "day": state.day, "articles": state.weekArticles.duplicate(true), "reputationAtStart": state.reputation, "pressureAtStart": state.pressure})
		state.merge({"reputation": report.reputation, "maxReputation": report.maxReputation, "evidence": report.evidence,
			"pressure": report.pressure, "suspendedNextWeek": report.strike == 2,
			"difficultyOffset": minf(c.maxDifficultyOffset, state.difficultyOffset + (1 if report.strike != null and report.strike >= 1 else 0)),
			"zeroRepStreak": state.zeroRepStreak + 1 if report.reputation == 0 else 0}, true)
		for id: String in state.fatigue:
			state.fatigue[id] = maxf(0, state.fatigue[id] - c.fatigueNight - c.fatigueWeekend)
		state.reports.append(report)
		note(state, "publication", "src.core.game.so_value0_value1_diem_value2", {"value0": state.week, "value1": floorf(report.score + 0.5), "value2": {"text_key": report.label_key, "parameters": {}}}, report)
		state.weekArticles = []
		state.selectedArticleIds = []
		state.workedToday = []
		state.day += 1
		state.week = minf(c.weeks, floorf((state.day - 1) / c.daysPerWeek) + 1)
		state.energy = c.dailyEnergy
		state.outcome = MATH.outcome(state)
	else:
		for id: String in state.fatigue:
			state.fatigue[id] = maxf(0, state.fatigue[id] - c.fatigueNight)
		state.day += 1
		state.workedToday = []
		state.energy = c.dailyEnergy
		note(state, "day", "src.core.game.bat_dau_ngay_value0", {"value0": state.day})
