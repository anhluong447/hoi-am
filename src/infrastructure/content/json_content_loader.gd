class_name JsonContentLoader
extends RefCounted
## Reads authored dictionaries. Validation of game definitions belongs to domain.


static func read_dictionary(path: String) -> Dictionary:
	var normalized := path.simplify_path()
	if not normalized.begins_with("res://content/") or normalized.get_extension() != "json":
		return {"ok": false, "error": {"code": "invalid_content_path", "path": path}}
	var file := FileAccess.open(normalized, FileAccess.READ)
	if file == null:
		return {"ok": false, "error": {"code": "content_unreadable", "path": path}}
	var parser := JSON.new()
	var status := parser.parse(file.get_as_text())
	file.close()
	if status != OK:
		return {
			"ok": false,
			"error": {"code": "invalid_content_json", "path": path, "line": parser.get_error_line()},
		}
	if not parser.data is Dictionary:
		return {"ok": false, "error": {"code": "invalid_content_root", "path": path}}
	return {"ok": true, "data": parser.data}
