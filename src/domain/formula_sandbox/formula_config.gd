extends RefCounted


static func validate(c: Variant, defaults: Dictionary) -> bool:
	if not c is Dictionary or c.size() != defaults.size():
		return false
	for key: String in defaults:
		if not c.has(key):
			return false
		if (defaults[key] is Array) != (c[key] is Array):
			return false
		var values: Array = c[key] if c[key] is Array else [c[key]]
		for value: Variant in values:
			if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(value) or value < 0:
				return false
	for key: String in ["weeks", "daysPerWeek", "dailyEnergy", "slots"]:
		if not c[key] is float and not c[key] is int:
			return false
		if c[key] < 1 or c[key] != floorf(c[key]):
			return false
	if c.weeks != 12 or c.daysPerWeek != 5 or c.slots != 4:
		return false
	for key: String in ["scoutCost", "maxScore", "qualityCap", "qualityFail", "evidenceRequired"]:
		if not c[key] is float and not c[key] is int:
			return false
		if c[key] <= 0:
			return false
	for key: String in ["fatigueFactor", "reputationAlpha", "pressureDecay", "pressureCarry", "suspensionMultiplier", "vanPenalty", "vanPenaltyCap", "soloSupport"]:
		if not c[key] is float and not c[key] is int:
			return false
		if c[key] > 1:
			return false
	if c.qualityFail > c.qualityCap or c.initialReputation > 100 or c.reputationRequired > 100:
		return false
	for pair: Array in [["slotWeights", 4], ["equipmentThresholds", 3], ["actThresholds", 3], ["strikeFractions", 2], ["strikeReputation", 3], ["scheduledWeeks", 2]]:
		if not c[pair[0]] is Array or c[pair[0]].size() != pair[1]:
			return false
	for index: int in 3:
		if c.equipmentThresholds[index] > 100 or (index > 0 and c.equipmentThresholds[index] <= c.equipmentThresholds[index - 1]) or c.actThresholds[index] <= 0:
			return false
	if c.strikeFractions[0] > c.strikeFractions[1] or c.strikeFractions[1] > 1:
		return false
	for week: float in c.scheduledWeeks:
		if week != floorf(week) or week < 1 or week > 12:
			return false
	return true
