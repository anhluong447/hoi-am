extends RefCounted

const NUMBERS = preload("res://src/domain/gameplay/gameplay_config.gd")


static func people(state: Dictionary, pack: Dictionary) -> bool:
	if state.people.size() != pack.roster.size() or not unique(state.people):
		return false
	var ids: Array = pack.roster.map(func(p: Dictionary) -> String: return p.id)
	var stats: Array = pack.stats.map(func(p: Dictionary) -> String: return p.id)
	for candidate: Dictionary in state.people:
		if candidate.id not in ids or not candidate.get("name_key") is String or not NUMBERS.integer(candidate.get("joinDay"), 1, state.config.days):
			return false
		if not candidate.get("stats") is Dictionary:
			return false
		for key: String in stats:
			if not NUMBERS.number(candidate.stats.get(key)):
				return false
		for key: String in ["female", "romance", "weekendSkill"]:
			if typeof(candidate.get(key)) != TYPE_BOOL:
				return false
		if not NUMBERS.number(candidate.get("fatigue")) or not NUMBERS.integer(candidate.get("bond")) or not NUMBERS.integer(candidate.get("events")):
			return false
		if not candidate.get("tools") is Array or not candidate.get("skills") is Array:
			return false
		var tools: Array = candidate.tools
		if tools.size() != _unique_values(tools).size():
			return false
		for tool: Variant in tools:
			if tool not in stats:
				return false
		for skill: Variant in candidate.skills:
			if skill != "synergy":
				return false
	return true


static func work(state: Dictionary, pack: Dictionary) -> bool:
	var ids: Array = pack.roster.map(func(p: Dictionary) -> String: return p.id)
	var stats: Array = pack.stats.map(func(p: Dictionary) -> String: return p.id)
	for key: String in ["cases", "quests", "drafts", "articles", "messages"]:
		if not unique(state[key]):
			return false
	for item: Dictionary in state.cases:
		if item.get("status") not in ["available", "working", "blocked", "draft", "expired", "cancelled"] or item.get("need") not in stats:
			return false
		if item.get("owner") != null and item.owner not in ids:
			return false
		if item.status in ["working", "blocked", "draft"] and item.owner not in ids:
			return false
		for key: String in ["title_key", "story_key", "teaser_key", "key"]:
			if not item.get(key) is String:
				return false
		for key: String in ["week", "expires", "progress", "attempts"]:
			if not NUMBERS.integer(item.get(key)):
				return false
		for key: String in ["quality", "attraction", "difficulty"]:
			if not NUMBERS.number(item.get(key)):
				return false
		if typeof(item.get("opened")) != TYPE_BOOL:
			return false
	for quest: Dictionary in state.quests:
		if not quest.get("title_key") is String or typeof(quest.get("written")) != TYPE_BOOL or not quest.get("steps") is Array or not quest.get("quality") is Array:
			return false
		if quest.steps.size() != _unique_values(quest.steps).size() or quest.quality.size() != quest.steps.size():
			return false
		for step: Variant in quest.steps:
			if step not in ["interview", "photo", "documents", "courage"]:
				return false
		for quality: Variant in quest.quality:
			if not NUMBERS.number(quality, 0, 1):
				return false
	for item: Dictionary in state.drafts + state.articles:
		if item.get("author") not in ids or item.get("branch") not in ["khue", "team"] or not item.get("title_key") is String:
			return false
		if not NUMBERS.number(item.get("quality"), 0, 1) or not NUMBERS.number(item.get("attraction")) or not NUMBERS.integer(item.get("readyDay"), 1, state.config.days):
			return false
		if item.has("processed") and typeof(item.processed) != TYPE_BOOL:
			return false
	for article: Dictionary in state.articles:
		if not NUMBERS.number(article.get("score"), 0, pack.balance.PUBLICATION.maxScore) or typeof(article.get("selected")) != TYPE_BOOL or typeof(article.get("published")) != TYPE_BOOL:
			return false
		if article.has("publishedDay") and not NUMBERS.integer(article.publishedDay, 1, state.config.days):
			return false
	for message: Dictionary in state.messages:
		if message.get("kind") not in ["progress", "complete", "mismatch"] or typeof(message.get("resolved")) != TYPE_BOOL or not NUMBERS.integer(message.get("day"), 1, state.config.days):
			return false
		if not state.cases.any(func(c: Dictionary) -> bool: return c.id == message.get("caseId")):
			return false
	for report: Dictionary in state.reports:
		if not NUMBERS.integer(report.get("day"), 1, state.config.days) or not NUMBERS.integer(report.get("week"), 1) or not NUMBERS.number(report.get("score")) or not NUMBERS.number(report.get("reputation")) or not report.get("ids") is Array:
			return false
		for id: Variant in report.ids:
			if not state.articles.any(func(a: Dictionary) -> bool: return a.id == id):
				return false
	return true


static func unique(items: Array) -> bool:
	var ids: Array = []
	for item: Variant in items:
		if not item is Dictionary or not item.get("id") is String or item.id.is_empty() or item.id in ids:
			return false
		ids.append(item.id)
	return true


static func _unique_values(items: Array) -> Array:
	var values: Array = []
	for item: Variant in items:
		if item not in values:
			values.append(item)
	return values
