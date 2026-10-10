class_name TextCatalog
extends RefCounted
## Formats an injected catalog; no file access or global locale state.

var _entries: Dictionary = {}
var _placeholders := RegEx.new()


func _init() -> void:
	_placeholders.compile("\\{([a-zA-Z][a-zA-Z0-9_]*)\\}")


func set_catalog(entries: Dictionary) -> Dictionary:
	for key: Variant in entries:
		if not key is String or not entries[key] is String:
			return {"ok": false, "error": {"code": "invalid_catalog_entry"}}
	_entries = entries.duplicate(true)
	return {"ok": true}


func format_text(key: String, parameters: Dictionary = {}) -> Dictionary:
	if not _entries.has(key):
		return {"ok": false, "error": {"code": "missing_text_key", "key": key}}
	var template: String = _entries[key]
	var parts := PackedStringArray()
	var cursor := 0
	for placeholder: RegExMatch in _placeholders.search_all(template):
		var parameter := placeholder.get_string(1)
		if not parameters.has(parameter):
			return {
				"ok": false,
				"error": {"code": "missing_text_parameter", "key": key, "parameter": parameter},
			}
		parts.append(template.substr(cursor, placeholder.get_start() - cursor))
		parts.append(str(parameters[parameter]))
		cursor = placeholder.get_end()
	parts.append(template.substr(cursor))
	return {"ok": true, "text": "".join(parts)}
