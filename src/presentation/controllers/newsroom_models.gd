extends RefCounted

const SUMMARY = preload("res://src/domain/gameplay/gameplay_summary.gd")


static func rows(section: String, s: Dictionary, pack: Dictionary, text: RefCounted) -> Array:
	var result: Array = []
	match section:
		"cases":
			for c: Dictionary in s.cases:
				if c.status == "expired" or c.status == "cancelled":
					continue
				result.append(copy(text.text("play.case_status", {"title": _title(c, text), "status": text.text("play.status." + c.status), "progress": c.progress, "days": s.config.researchDays, "quality": snappedf(c.quality * 100, 0.1)})))
				result.append(copy(text.text(c.story_key if c.opened else c.teaser_key)))
				if c.status == "available" and not c.opened:
					result.append(action(text.text("play.open", {"energy": s.config.openCost}), {"type": "open", "id": c.id}))
				elif c.status == "available":
					for p: Dictionary in s.people:
						if p.id != "khue" and p.joinDay <= s.day:
							result.append(action(text.text("play.assign", {"name": text.text(p.name_key), "energy": s.config.assignCost}), {"type": "assign", "id": c.id, "person": p.id}))
		"quests":
			for q: Dictionary in s.quests:
				result.append(copy(_title(q, text)))
				if not q.written:
					for step: Dictionary in pack.quest_steps:
						if step.id not in q.steps:
							result.append(action(text.text("play.quest_step", {"step": text.text(step.name_key), "energy": pack.balance.RESEARCH.stepCost}), {"type": "quest", "id": q.id, "step": step.id}))
					if q.steps.size() == pack.quest_steps.size():
						result.append(action(text.text("play.write", {"energy": pack.balance.RESEARCH.stepCost}), {"type": "write", "id": q.id}))
		"team":
			for p: Dictionary in s.people:
				if p.joinDay > s.day:
					continue
				var name: String = text.text(p.name_key)
				result.append(copy(text.text("play.person", {"name": name, "fatigue": p.fatigue, "bond": p.bond, "events": p.events, "romance": _yes(p.romance, text)})))
				for stat: Dictionary in pack.stats:
					result.append(copy(text.text("play.stat", {"stat": text.text(stat.name_key), "value": p.stats[stat.id]})))
				result.append(action(text.text("play.talk", {"name": name}), {"intent": "talk", "id": p.id}))
		"editorial":
			result.append(copy(text.text("play.editorial_capacity", {"capacity": s.config.editorialCapacity})))
			for draft: Dictionary in s.drafts:
				result.append(copy(text.text("play.draft", {"title": _title(draft, text), "day": draft.readyDay, "processed": _yes(draft.get("processed", false), text)})))
			if s.phase == "bed":
				result.append(action(text.text("migration.calendar.sleep"), {"type": "sleep"}))
			for m: Dictionary in s.messages:
				if m.resolved:
					continue
				result.append(copy(text.text("play.feedback", {"id": m.caseId, "kind": text.text("play.feedback." + m.kind)})))
				for option: String in ["continue", "short", "cancel"]:
					result.append(action(text.text("play." + option), {"type": "approve", "id": m.id, "option": option}))
				for p: Dictionary in s.people:
					if p.id != "khue" and p.joinDay <= s.day:
						result.append(action(text.text("play.reassign", {"name": text.text(p.name_key)}), {"type": "approve", "id": m.id, "option": "reassign", "person": p.id}))
			for a: Dictionary in s.articles:
				result.append(copy(text.text("play.article", {"title": _title(a, text), "score": a.score, "selected": _yes(a.selected, text), "published": _yes(a.published, text)})))
				if not a.published:
					result.append(action(text.text("play.select", {"title": _title(a, text)}), {"type": "select", "id": a.id}))
		"reports":
			result.append(copy(text.text("play.metrics", s.metrics)))
			var summary := SUMMARY.summarize(s, pack)
			summary.good = _yes(summary.good, text)
			for field: String in ["K", "T", "total"]:
				summary[field] = snappedf(summary[field], 0.1)
			result.append(copy(text.text("play.summary", summary)))
			for r: Dictionary in s.reports:
				result.append(copy(text.text("play.report", r)))
			for event: Dictionary in s.log.slice(maxi(0, s.log.size() - 60)):
				result.append(copy(text.text(event.textKey, event.params) if event.has("textKey") else event.message))
	return result


static func copy(value: String) -> Dictionary:
	return {"text": value}


static func action(value: String, command: Dictionary) -> Dictionary:
	return {"text": value, "command": command}


static func _title(item: Dictionary, text: RefCounted) -> String:
	return text.text(item.title_key, item.get("title_parameters", {}))


static func _yes(value: bool, text: RefCounted) -> String:
	return text.text("play.yes" if value else "play.no")
