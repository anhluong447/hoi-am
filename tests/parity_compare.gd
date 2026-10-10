extends RefCounted

const TEXT = preload("res://src/presentation/controllers/gameplay_text.gd")

var _text: RefCounted


func _init(catalog: RefCounted) -> void:
	_text = TEXT.new(catalog)


func compatibility(state: Dictionary) -> Dictionary:
	var result := state.duplicate(true)
	result.version = 2
	for person: Dictionary in result.people:
		person.name = _text.text(person.name_key)
		person.erase("name_key")
	for item: Dictionary in result.cases + result.quests + result.drafts + result.articles:
		for field: String in ["title", "story", "teaser"]:
			if item.has(field + "_key"):
				item[field] = _text.text(item[field + "_key"], item.get(field + "_parameters", {}))
				item.erase(field + "_key")
				item.erase(field + "_parameters")
	for event: Dictionary in result.log:
		if event.has("params"):
			event.params = _text.resolve(event.params)
	return result


func events(items: Array) -> Array:
	var result := items.duplicate(true)
	for event: Dictionary in result:
		event.params = _text.resolve(event.params)
	return result


static func difference(expected: Variant, actual: Variant, path: String = "state") -> String:
	if expected is Dictionary and actual is Dictionary:
		if expected.size() != actual.size():
			return "%s keys %s != %s" % [path, expected.keys(), actual.keys()]
		for key: String in expected:
			if not actual.has(key):
				return path + ".missing:" + key
			var nested := difference(expected[key], actual[key], path + "." + key)
			if not nested.is_empty():
				return nested
		return ""
	if expected is Array and actual is Array:
		if expected.size() != actual.size():
			return "%s lengths %d != %d" % [path, expected.size(), actual.size()]
		for index: int in expected.size():
			var nested := difference(expected[index], actual[index], "%s[%d]" % [path, index])
			if not nested.is_empty():
				return nested
		return ""
	if typeof(expected) in [TYPE_INT, TYPE_FLOAT] and typeof(actual) in [TYPE_INT, TYPE_FLOAT]:
		var valid: bool = expected == actual if floor(float(expected)) == expected else absf(expected - actual) <= 1e-8
		return "" if valid else "%s numeric %s != %s" % [path, expected, actual]
	if typeof(expected) != typeof(actual) or expected != actual:
		return "%s value %s != %s" % [path, expected, actual]
	return ""
