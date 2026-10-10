extends RefCounted
## Concrete runtime gameplay pack validation before a ruleset is instantiated.

const NUMBERS = preload("res://src/domain/gameplay/gameplay_config.gd")
const RECORDS = preload("res://src/domain/gameplay/record_validation.gd")
const REQUIRED_TUNING = {
	"DEFAULTS": ["days", "clubEnergy", "outsideEnergy", "openCost", "assignCost", "researchDays", "editorialCapacity", "packaging", "romancePenalty", "fatiguePerWork", "recovery", "jobPay", "trainingCost", "toolCost", "giftCost"],
	"CALENDAR": ["daysPerWeek", "schoolDays", "publicationDay", "minDays", "maxDays"],
	"LIMITS": ["packaging", "minRomancePenalty", "maxRomancePenalty"],
	"FATIGUE": ["minimumEfficiency", "divisor", "cap"],
	"RESEARCH": ["lifetime", "toolBonus", "synergyBonus", "statScale"],
	"PUBLICATION": ["maxScore", "khueMultiplier", "slots", "reputationScale", "emptyLoss", "pressure", "grantFrequency", "baseGrants", "grantThreshold"],
	"PERSONAL": ["initialMoney", "restRecovery", "betrayalBondLoss"]
}


static func validate(pack: Dictionary, catalog: Dictionary) -> Dictionary:
	if pack.get("schema_version") != 1 or not pack.get("balance") is Dictionary:
		return _invalid("schema")
	for group: String in ["DEFAULTS", "CALENDAR", "LIMITS", "FATIGUE", "RESEARCH", "PUBLICATION", "PERSONAL", "SUMMARY"]:
		if not pack.balance.get(group) is Dictionary:
			return _invalid(group)
		for value: Variant in pack.balance[group].values():
			if not NUMBERS.number(value):
				return _invalid("tuning_number")
	for group: String in REQUIRED_TUNING:
		for field: String in REQUIRED_TUNING[group]:
			if not pack.balance[group].has(field):
				return _invalid("missing_" + group + "_" + field)
	for pair: Array in [["CALENDAR", "daysPerWeek"], ["RESEARCH", "statScale"], ["FATIGUE", "divisor"], ["PUBLICATION", "reputationScale"], ["PUBLICATION", "grantFrequency"]]:
		if not NUMBERS.number(pack.balance[pair[0]].get(pair[1]), 0.000001):
			return _invalid("tuning_divisor")
	var calendar: Dictionary = pack.balance.CALENDAR
	for key: String in ["daysPerWeek", "schoolDays", "publicationDay", "minDays", "maxDays"]:
		if not NUMBERS.integer(calendar.get(key)):
			return _invalid("calendar_tuning")
	if calendar.schoolDays >= calendar.daysPerWeek or calendar.publicationDay >= calendar.schoolDays:
		return _invalid("calendar_order")
	for field: String in ["stats", "roster", "cases", "quest_steps", "phases", "places"]:
		if not pack.get(field) is Array or pack[field].is_empty():
			return _invalid(field)
		if field != "cases" and not RECORDS.unique(pack[field]):
			return _invalid("duplicate_" + field)
	var stats: Array = pack.stats.map(func(item: Dictionary) -> String: return item.id)
	var actors: Array = pack.roster.map(func(item: Dictionary) -> String: return item.id)
	if "khue" not in actors or "van" not in actors:
		return _invalid("required_actors")
	for actor: Dictionary in pack.roster:
		if not actor.get("stats") is Dictionary or actor.stats.size() != stats.size() or typeof(actor.get("female")) != TYPE_BOOL or not NUMBERS.integer(actor.get("joinDay"), 1, calendar.maxDays):
			return _invalid("roster_shape")
		for stat: String in stats:
			if not NUMBERS.number(actor.stats.get(stat)):
				return _invalid("roster_stat")
	var case_ids: Array = []
	for item: Variant in pack.cases:
		if not item is Dictionary or not item.get("key") is String or item.key in case_ids or item.get("need") not in stats:
			return _invalid("case_reference")
		case_ids.append(item.key)
		if not NUMBERS.number(item.get("difficulty"), 0.000001) or not NUMBERS.number(item.get("attraction")):
			return _invalid("case_tuning")
	if not _keys(pack, catalog):
		return _invalid("text_keys")
	if not pack.get("legacy_skills") is Dictionary:
		return _invalid("migration_ids")
	var configured := NUMBERS.validate(pack.balance.DEFAULTS, pack.balance)
	return {"ok": true} if configured.ok else configured


static func _keys(value: Variant, catalog: Dictionary) -> bool:
	if value is Dictionary:
		for key: String in value:
			if key.ends_with("_key") and not catalog.has(value[key]):
				return false
			if not _keys(value[key], catalog):
				return false
	elif value is Array:
		for item: Variant in value:
			if not _keys(item, catalog):
				return false
	return true


static func _invalid(field: String) -> Dictionary:
	return {"ok": false, "error": {"code": "invalid_gameplay_content", "field": field}}
