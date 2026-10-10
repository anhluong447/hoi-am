extends Node

signal loaded(world: Dictionary)
signal status_changed(message: String)

const STORE = preload("res://src/infrastructure/saves/file_save_store.gd")
const SAVES = preload("res://src/application/gameplay_saves.gd")

var _store: RefCounted
var _service: RefCounted
var _text: RefCounted
var _world: Callable
var _confirm: ConfirmationDialog
var _picker: FileDialog
var _pending: Dictionary
var _payload: Variant


func configure(setup: Dictionary, world_snapshot: Callable) -> void:
	_store = STORE.new()
	_service = SAVES.new(setup.session, setup.data.gameplay, _store.read_slot, _store.write_slot, setup.validator.validate, setup.data.locations.legacy_maps)
	_text = setup.text
	_world = world_snapshot


func _ready() -> void:
	_confirm = ConfirmationDialog.new()
	_confirm.ok_button_text = _text.text("play.confirm")
	_confirm.cancel_button_text = _text.text("play.close")
	_confirm.title = _text.text("play.saves")
	_confirm.confirmed.connect(_confirmed)
	add_child(_confirm)
	_picker = FileDialog.new()
	_picker.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_picker.access = FileDialog.ACCESS_FILESYSTEM
	_picker.title = _text.text("play.import")
	_picker.add_filter("*.json,*.bak")
	_picker.file_selected.connect(_selected)
	add_child(_picker)


func request(intent: Dictionary) -> void:
	_pending = intent.duplicate(true)
	if intent.intent == "import":
		_picker.popup_centered_ratio(0.7)
		return
	_confirm.dialog_text = _text.text("play.confirm_" + intent.intent, {"slot": intent.number})
	_confirm.popup_centered()


func _selected(path: String) -> void:
	var result: Dictionary = _store.read_file(path)
	if not result.ok:
		_status(result)
		return
	_payload = result.payload
	_confirm.dialog_text = _text.text("play.confirm_import")
	_confirm.popup_centered()


func _confirmed() -> void:
	var result: Dictionary
	var time := Time.get_datetime_string_from_system()
	match _pending.intent:
		"save":
			result = _service.save(_pending.slot, _world.call(), time)
		"load":
			result = _service.load_slot(_pending.slot)
		"import":
			result = _service.import_payload(_payload)
			_payload = null
		_:
			return
	if result.ok:
		if result.has("world"):
			loaded.emit(result.world)
		status_changed.emit(_text.text("play.saved", {"time": time}) if _pending.intent == "save" else _text.text("play.loaded"))
	else:
		_status(result)


func _status(result: Dictionary) -> void:
	status_changed.emit(_text.text(result.error.text_key, result.error.get("parameters", {})))
