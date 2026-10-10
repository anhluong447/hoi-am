extends RefCounted

const RULES = preload("res://src/domain/formula_sandbox/formula_rules.gd")
const MATH = preload("res://src/domain/formula_sandbox/formula_math.gd")


static func run_day(session: RefCounted, policy: Dictionary) -> Dictionary:
	var state: Dictionary = session.snapshot()
	var safe: bool = policy.get("safe", false) or (policy.get("late", false) and state.week <= 5)
	for _guard: int in 20:
		if state.weekArticles.size() >= policy.cap:
			break
		var candidates: Array = RULES.active_subjects(state).filter(func(s: Dictionary) -> bool: return s.energy <= state.energy and (not safe or (s.pressure if s.scouted else s.previewPressure) <= 6))
		candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var av := _value(a, state, policy)
			var bv := _value(b, state, policy)
			return av > bv if av != bv else a.id < b.id)
		if candidates.is_empty():
			break
		var subject: Dictionary = candidates[0]
		var command: Dictionary
		if policy.get("scout", false) and not subject.scouted and state.energy >= subject.energy + state.config.scoutCost:
			command = {"type": "scout", "id": subject.id}
		else:
			var staff := RULES.active_staff(state)
			var without_van: Array = staff.filter(func(p: Dictionary) -> bool: return p.id != "van")
			if policy.get("noVan", false) and without_van.size() >= 2:
				staff = without_van
			var pair: Array = []
			var best := -INF
			if policy.get("solo", false):
				for p: Dictionary in staff:
					if p.id == "khue":
						pair = [p.id, null]
			else:
				for a: Dictionary in staff:
					for b: Dictionary in staff:
						if a.id != b.id:
							var power := MATH.power(a, b, subject, state.fatigue, state.config)
							if power > best:
								best = power
								pair = [a.id, b.id]
				if pair.is_empty() and staff.size() == 1 and staff[0].id == "khue":
					pair = ["khue", null]
			if pair.is_empty():
				break
			command = {"type": "interview", "id": subject.id, "reporter": pair[0], "supporter": pair[1]}
		var result: Dictionary = session.execute(command)
		if not result.ok:
			return result
		state = result.state
	if policy.get("scout", false) and state.energy >= state.config.scoutCost:
		var candidates: Array = RULES.active_subjects(state).filter(func(s: Dictionary) -> bool: return not s.scouted)
		candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return _value(a, state, policy) > _value(b, state, policy))
		if not candidates.is_empty():
			var result: Dictionary = session.execute({"type": "scout", "id": candidates[0].id})
			if not result.ok:
				return result
			state = result.state
	if int(state.day) % int(state.config.daysPerWeek) == 0:
		var grit: float = 0.0 if safe else policy.get("grit", 0.6 if state.pressure < 40 else 0.4 if state.pressure < 70 else 0.2)
		for article: Dictionary in state.weekArticles:
			var result: Dictionary = session.execute({"type": "edit", "id": article.id, "grit": grit})
			if not result.ok:
				return result
		state = session.snapshot()
		var selected: Array = state.weekArticles.filter(func(a: Dictionary) -> bool: return a.score > 0)
		selected.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.score > b.score)
		var ids: Array = selected.slice(0, 4).map(func(a: Dictionary) -> String: return a.id)
		var result: Dictionary = session.execute({"type": "select", "ids": ids})
		if not result.ok:
			return result
	return session.execute({"type": "next"})


static func _value(s: Dictionary, state: Dictionary, p: Dictionary) -> float:
	var attraction: float = s.attraction if s.scouted else s.preview
	var pressure: float = s.pressure if s.scouted else s.previewPressure
	var base: float = state.config.maxScore * pow(attraction / 10.0, state.config.attractionExponent)
	if p.get("greedy", false):
		return base
	var pace: float = state.config.evidenceRequired * minf(1.0, state.week / 11.0)
	var bonus := 1.35 if s.main and state.evidence < pace else 1.0
	var penalty := 1.0 - minf(0.8, maxf(0.0, (pressure - 6.0) / 40.0)) if state.pressure > 60 else 1.0
	return base * bonus * penalty / pow(s.energy, 0.3)
