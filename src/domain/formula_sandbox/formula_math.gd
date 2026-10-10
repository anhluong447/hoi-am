extends RefCounted


static func equipment(reputation: float, config: Dictionary) -> int:
	var count := 0
	for threshold: float in config.equipmentThresholds:
		if reputation >= threshold:
			count += 1
	return count


static func power(reporter: Dictionary, supporter: Dictionary, subject: Dictionary, fatigue: Dictionary, config: Dictionary) -> float:
	var support: Dictionary = reporter if supporter.is_empty() else supporter
	var r: float = 1.0 - config.fatigueFactor * clampf(fatigue.get(reporter.id, 0), 0, 100) / 100.0
	var s: float = 1.0 - config.fatigueFactor * clampf(fatigue.get(support.id, 0), 0, 100) / 100.0
	return config.reporterWeight * reporter.stats.PV * r + config.supporterWeight * support.stats[subject.need] * s * (config.soloSupport if supporter.is_empty() else 1.0)


static func quality(value: float, tools: int, difficulty: float, offset: float, config: Dictionary) -> float:
	return clampf(1.0 + (value + tools - difficulty - offset - config.qualityOffset) / 10.0, 0.0, config.qualityCap)


static func article(subject: Dictionary, q: float, grit: float, config: Dictionary) -> Dictionary:
	if q < config.qualityFail:
		return {"score": 0, "pressure": 0, "evidence": 0}
	var g := clampf(grit, 0.0, 1.0)
	return {"score": minf(config.maxScore, config.maxScore * pow(subject.attraction / 10.0, config.attractionExponent) * q * (config.scoreBase + config.scoreGrit * g)),
		"pressure": subject.pressure * (config.pressureBase + g), "evidence": config.evidenceBase * q * (config.pressureBase + g) if subject.main else 0.0}


static func outcome(state: Dictionary) -> Variant:
	if state.zeroRepStreak >= 2:
		return "disbanded"
	if state.day <= state.config.weeks * state.config.daysPerWeek:
		return null
	if state.evidence < state.config.evidenceRequired:
		return "defeat"
	return "win" if state.reputation >= state.config.reputationRequired else "bitter"


static func paper_key(score: float) -> String:
	var keys := ["ui.banger", "src.core.rules.lan_ra_ngoai_truong", "src.core.rules.duoc_quan_tam", "src.core.rules.duoc_nhac_den", "src.core.rules.lac_dac_ban_tan", "src.core.rules.chua_thu_hut", "src.core.rules.chang_ai_quan_tam"]
	var thresholds := [90000, 60000, 30000, 5000, 500, 50, 0]
	for index: int in thresholds.size():
		if score >= thresholds[index]:
			return keys[index]
	return keys[-1]


static func preview(state: Dictionary) -> Dictionary:
	var c: Dictionary = state.config
	var selected: Array = state.weekArticles.filter(func(a: Dictionary) -> bool: return a.id in state.selectedArticleIds)
	selected.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.score > b.score if a.score != b.score else a.id < b.id)
	var weighted := 0.0
	var evidence := 0.0
	var pressure := 0.0
	var real_count := 0
	var ids: Array = []
	for index: int in selected.size():
		var a: Dictionary = selected[index]
		weighted += (c.slotWeights[index] if index < c.slotWeights.size() else 0.0) * a.score
		evidence += a.evidence
		pressure += a.pressure
		real_count += 1 if a.score > 0 else 0
		ids.append(a.id)
	var van_tasks: int = state.weekArticles.filter(func(a: Dictionary) -> bool: return a.reporterId == "van" or a.supporterId == "van").size()
	var van_multiplier: float = 1.0 - minf(c.vanPenaltyCap, c.vanPenalty * van_tasks)
	var suspension: float = c.suspensionMultiplier if state.suspendedNextWeek else 1.0
	var score := minf(c.maxScore, weighted) * van_multiplier * suspension
	var reputation := clampf((1.0 - c.reputationAlpha) * state.reputation + c.reputationAlpha * score / 1000.0 - c.emptyPenalty * (c.slots - real_count) - (c.blankPenalty if real_count == 0 else 0), 0, 100)
	var before_pressure: float = state.pressure * c.pressureDecay + pressure
	var threshold: float = c.actThresholds[0 if state.week <= 3 else 1 if state.week <= 7 else 2]
	var emergency := before_pressure >= threshold
	var scheduled: bool = c.scheduledWeeks.any(func(w: float) -> bool: return w == state.week)
	var strike: Variant = 2 if emergency else (0 if before_pressure < threshold * c.strikeFractions[0] else 1 if before_pressure < threshold * c.strikeFractions[1] else 2) if scheduled else null
	var penalty: float = 0.0 if strike == null else c.strikeReputation[strike]
	return {"selectedIds": ids, "weightedScore": weighted, "vanTasks": van_tasks, "vanMultiplier": van_multiplier,
		"suspensionMultiplier": suspension, "score": score, "realCount": real_count,
		"reputationBeforeStrike": reputation, "reputationPenalty": penalty, "reputation": maxf(0, reputation - penalty),
		"evidenceGain": evidence, "evidence": state.evidence + evidence, "pressureGain": pressure, "pressureBeforeStrike": before_pressure,
		"pressure": before_pressure if strike == null else before_pressure * c.pressureCarry,
		"strike": strike, "emergency": emergency, "scheduled": scheduled, "threshold": threshold,
		"label_key": paper_key(score), "maxReputation": maxf(state.maxReputation, reputation)}
