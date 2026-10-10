extends RefCounted


static func validate(config: Dictionary, balance: Dictionary) -> Dictionary:
	var defaults: Dictionary = balance.DEFAULTS
	if config.size() != defaults.size():
		return {"ok": false, "error": {"code": "invalid_config_fields"}}
	for key: String in defaults:
		var value: Variant = config.get(key)
		if not number(value) or value < 0:
			return {"ok": false, "error": {"code": "invalid_config_number", "field": key}}
	var calendar: Dictionary = balance.CALENDAR
	if not integer(config.days, calendar.minDays, calendar.maxDays) or int(config.days) % int(calendar.daysPerWeek) != 0:
		return {"ok": false, "error": {"code": "invalid_config_days"}}
	if not integer(config.researchDays, 1) or not integer(config.editorialCapacity, 1):
		return {"ok": false, "error": {"code": "invalid_config_capacity"}}
	var limits: Dictionary = balance.LIMITS
	if config.packaging > limits.packaging or config.romancePenalty < limits.minRomancePenalty or config.romancePenalty > limits.maxRomancePenalty:
		return {"ok": false, "error": {"code": "invalid_config_tuning"}}
	return {"ok": true}


static func number(value: Variant, minimum: float = 0.0, maximum: float = INF) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and value >= minimum and value <= maximum


static func integer(value: Variant, minimum: float = 0.0, maximum: float = INF) -> bool:
	return number(value, minimum, maximum) and floor(float(value)) == float(value)
