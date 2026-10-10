extends RefCounted


static func week(day: int, calendar: Dictionary) -> int:
	return int(floor(float(day - 1) / calendar.daysPerWeek)) + 1


static func weekend(day: int, calendar: Dictionary) -> bool:
	return (day - 1) % int(calendar.daysPerWeek) >= calendar.schoolDays


static func consume_slot(state: Dictionary) -> void:
	var phase: String = state.get("investigationFrom", state.phase)
	state.phase = {"personal": "evening", "evening": "bed", "weekend1": "weekend2", "weekend2": "evening"}[phase]
	state.erase("investigationFrom")
