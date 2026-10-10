extends RefCounted

const CONTRACT = preload("res://src/domain/gameplay/save_contract.gd")

var _session: RefCounted
var _pack: Dictionary
var _read: Callable
var _write: Callable
var _validator: Callable
var _legacy_maps: Dictionary


func _init(session: RefCounted, pack: Dictionary, read: Callable, write: Callable, validator: Callable, legacy_maps: Dictionary = {}) -> void:
	_session = session
	_pack = pack.duplicate(true)
	_read = read
	_write = write
	_validator = validator
	_legacy_maps = legacy_maps.duplicate(true)


func save(slot: String, world: Dictionary, saved_at: String) -> Dictionary:
	if not CONTRACT.valid_world(world) or not _validator.call(_session.snapshot()).ok:
		return {"ok": false, "error": {"code": "invalid_save", "text_key": "save.invalid"}}
	return _write.call(slot, CONTRACT.envelope(_session.snapshot(), world, saved_at))


func load_slot(slot: String) -> Dictionary:
	var result: Dictionary = _read.call(slot)
	return import_payload(result.payload) if result.ok else result


func import_payload(payload: Variant) -> Dictionary:
	var decoded := CONTRACT.decode(payload, _pack, _legacy_maps)
	if not decoded.ok:
		return decoded
	var replaced: Dictionary = _session.replace(decoded.state)
	if not replaced.ok:
		return replaced
	return {"ok": true, "world": decoded.world.duplicate(true)}
