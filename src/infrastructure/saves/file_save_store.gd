extends RefCounted
## One gameplay store; temporary write and recoverable previous revision.

var _root: String


func _init(root: String = "user://saves/gameplay") -> void:
	_root = root


func read_slot(slot: String) -> Dictionary:
	if not _valid_slot(slot):
		return _error("invalid_slot")
	return read_file(_path(slot))


func read_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _error("read_failed")
	var parser := JSON.new()
	var status := parser.parse(file.get_as_text())
	file.close()
	if status != OK or not parser.data is Dictionary:
		return _error("decode_failed")
	return {"ok": true, "payload": parser.data}


func write_slot(slot: String, payload: Dictionary) -> Dictionary:
	if not _valid_slot(slot):
		return _error("invalid_slot")
	if DirAccess.make_dir_recursive_absolute(_root) != OK:
		return _error("directory_failed")
	var path := _path(slot)
	var temp := path + ".tmp"
	var backup := path + ".bak"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return _error("write_failed")
	file.store_string(JSON.stringify(payload, "", true, true))
	file.flush()
	var status := file.get_error()
	file.close()
	if status != OK or not read_file(temp).ok:
		return _error("write_failed")
	var had_previous := FileAccess.file_exists(path)
	if had_previous:
		if FileAccess.file_exists(backup) and DirAccess.remove_absolute(backup) != OK:
			return _error("backup_failed")
		if DirAccess.rename_absolute(path, backup) != OK:
			return _error("backup_failed")
	if DirAccess.rename_absolute(temp, path) != OK:
		if had_previous:
			DirAccess.rename_absolute(backup, path)
		return _error("commit_failed")
	return {"ok": true}


func _path(slot: String) -> String:
	return _root.path_join(slot + ".json")


static func _valid_slot(slot: String) -> bool:
	return slot in ["slot_1", "slot_2", "slot_3"]


static func _error(code: String) -> Dictionary:
	var key := "save.write_failed" if code in ["directory_failed", "write_failed", "backup_failed", "commit_failed"] else "save.read_failed" if code == "read_failed" else "save.invalid"
	return {"ok": false, "error": {"code": code, "text_key": key}}
