extends RefCounted

const ROWS = preload("res://src/presentation/controllers/newsroom_models.gd")


static func rows(state: Dictionary, pack: Dictionary, text: RefCounted, location: String, ui: Dictionary) -> Array:
	var result: Array = [ROWS.action(text.text("play.job", {"pay": state.config.jobPay}), {"type": "activity", "kind": "job"}),
		ROWS.action(text.text("play.boost", {"energy": pack.balance.PERSONAL.boostEnergy, "cost": pack.balance.PERSONAL.boostCost}), {"type": "boost"})]
	for p: Dictionary in state.people:
		if p.joinDay > state.day:
			continue
		var name: String = text.text(p.name_key)
		if p.id != "khue":
			result.append(ROWS.action(text.text("play.hangout", {"name": name}), {"type": "activity", "kind": "hangout", "person": p.id}))
			result.append(ROWS.action(text.text("play.gift", {"name": name, "cost": state.config.giftCost}), {"type": "gift", "person": p.id}))
			if p.female and not p.romance:
				result.append(ROWS.action(text.text("play.date", {"name": name}), {"type": "date", "person": p.id}))
		for stat: Dictionary in pack.stats:
			var label: String = text.text(stat.name_key)
			if p.id == "khue":
				result.append(ROWS.action(text.text("play.train", {"stat": label, "cost": state.config.trainingCost}), {"type": "activity", "kind": "train", "stat": stat.id}))
			elif state.grants > 0:
				result.append(ROWS.action(text.text("play.upgrade", {"name": name, "stat": label}), {"type": "upgrade", "person": p.id, "stat": stat.id}))
			if stat.id not in p.tools:
				result.append(ROWS.action(text.text("play.tool", {"name": name, "stat": label, "cost": state.config.toolCost}), {"type": "tool", "person": p.id, "stat": stat.id}))
	result.append(ROWS.action(text.text("migration.calendar.rest"), {"type": "activity", "kind": "rest"}))
	result.append(ROWS.action(text.text("migration.calendar.sleep"), {"type": "sleep"}))
	return result.filter(func(row: Dictionary) -> bool:
		var command: Dictionary = row.command
		var id: String = command.get("kind", "") if command.type == "activity" else command.type
		return location in ui.personal_locations.get(id, []))
