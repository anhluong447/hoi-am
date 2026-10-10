extends RefCounted
## Formats nested text references and numeric presentation outside the domain.

var _catalog: RefCounted


func _init(catalog: RefCounted) -> void:
	_catalog = catalog


func resolve(value: Variant) -> Variant:
	if value is float and value == floorf(value):
		return int(value)
	if value is Dictionary:
		if value.has("text_key"):
			var parameters: Dictionary = resolve(value.get("parameters", {}))
			var formatted: Dictionary = _catalog.format_text(value.text_key, parameters)
			assert(formatted.ok, "Invalid presentation text reference")
			return formatted.text
		if value.get("format") == "vi_integer":
			return integer_text(int(value.number))
		var result: Dictionary = {}
		for key: String in value:
			result[key] = resolve(value[key])
		return result
	if value is Array:
		return value.map(resolve)
	return value


func text(key: String, parameters: Dictionary = {}) -> String:
	var formatted: Dictionary = _catalog.format_text(key, resolve(parameters))
	assert(formatted.ok, "Invalid presentation text key or parameters")
	return formatted.get("text", "")


static func integer_text(value: int) -> String:
	var digits := str(absi(value))
	var grouped := ""
	for index: int in digits.length():
		if index > 0 and (digits.length() - index) % 3 == 0:
			grouped += "."
		grouped += digits[index]
	return ("-" if value < 0 else "") + grouped
