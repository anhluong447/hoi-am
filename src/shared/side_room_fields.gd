extends RefCounted
## Low level scalar/shape predicates shared by the side-room validators; pure,
## no I/O, no node or engine dependency beyond basic math helpers.

const HEX_CHARS := "0123456789abcdefABCDEF"


static func result(errors: Array[String]) -> Dictionary:
	return {"ok": errors.is_empty(), "errors": errors}


static func claim_id(value: Variant, shared_ids: Dictionary, errors: Array[String]) -> bool:
	if not is_id(value):
		errors.append("Entry is missing an id")
		return false
	if shared_ids.has(value):
		errors.append("Duplicate id across layers/props/doors/interactions: %s" % value)
		return false
	shared_ids[value] = true
	return true


static func is_id(value: Variant) -> bool:
	return value is String and not value.is_empty()


static func is_path(value: Variant) -> bool:
	return value is String and value.begins_with("res://")


static func is_finite_number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))


## Godot's JSON parser yields floats for every number; integral floats count.
static func is_integer(value: Variant) -> bool:
	return value is int or (value is float and is_finite(value) and value == floorf(value))


static func is_positive_number(value: Variant) -> bool:
	return is_finite_number(value) and float(value) > 0.0


static func is_position(value: Variant) -> bool:
	return value is Array and value.size() == 2 and is_finite_number(value[0]) and is_finite_number(value[1])


static func is_size(value: Variant) -> bool:
	return value is Array and value.size() == 2 and is_positive_number(value[0]) and is_positive_number(value[1])


static func is_color(value: Variant) -> bool:
	if not value is String or value.length() != 7 or value[0] != "#":
		return false
	for index in range(1, 7):
		if HEX_CHARS.find(value[index]) == -1:
			return false
	return true


static func is_sha256(value: Variant) -> bool:
	if not value is String or value.length() != 64:
		return false
	for index in range(0, 64):
		if HEX_CHARS.find(value[index]) == -1:
			return false
	return true
