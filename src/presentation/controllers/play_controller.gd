extends RefCounted

const CALENDAR = preload("res://src/presentation/controllers/calendar_controller.gd")
const ROWS = preload("res://src/presentation/controllers/newsroom_models.gd")
const PERSONAL = preload("res://src/presentation/controllers/personal_models.gd")
const GRAPH = preload("res://src/domain/dialogue/dialogue_graph.gd")

var section := "calendar"
var modal := ""
var location_id := "club"
var message := ""
var graph_id := ""
var node_id := "start"
var _session: RefCounted
var _text: RefCounted
var _data: Dictionary
var _graphs: Dictionary
var _calendar: RefCounted


func _init(session: RefCounted, text: RefCounted, data: Dictionary) -> void:
	_session = session
	_text = text
	_data = data.duplicate(true)
	_graphs = data.dialogue.scenes.duplicate(true)
	_graphs.merge(data.playable_dialogue.scenes)
	_calendar = CALENDAR.new(session, text, data.gameplay, data.preview)
	for graph: Dictionary in _graphs.values():
		assert(GRAPH.validate(graph, data.catalog), "Invalid authored dialogue graph")


func hud() -> Dictionary:
	var model: Dictionary = _calendar.model()
	var s: Dictionary = _session.snapshot()
	model.date = _text.text(_data.preview.weekday_keys[(int(s.day) - 1) % 7])
	model.phase = _text.text("play.phase." + s.phase, {"day": s.day})
	for place: Dictionary in _data.gameplay.places:
		if place.id == location_id:
			model.location = _text.text(place.name_key)
	model.menu = _text.text("ui.hud.menu")
	model.map = _text.text("ui.hud.map")
	model.objective = _text.text("ui.hud.objective.ended" if s.ended else "ui.hud.objective." + s.phase)
	return model


func prompt(label_key: String) -> String:
	return "" if label_key.is_empty() else _text.text("migration.world.prompt", {"target": _text.text(label_key)})


func execute(command: Dictionary) -> Dictionary:
	var result: Dictionary = _calendar.execute(command)
	message = result.message
	return result


func workspace() -> Dictionary:
	var state: Dictionary = _session.snapshot()
	var rows: Array = ROWS.rows(section, state, _data.gameplay, _text)
	match section:
		"calendar":
			for item: Dictionary in _data.preview.calendar_commands:
				rows.append(ROWS.action(_text.text(item.text_key), item.command))
		"life":
			rows = PERSONAL.rows(state, _data.gameplay, _text, location_id, _data.workspace)
		"travel":
			for place: Dictionary in _data.gameplay.places:
				rows.append(ROWS.action(_text.text(place.name_key), {"intent": "travel", "id": place.id}))
		"saves":
			for slot: int in range(1, 4):
				for intent: String in ["save", "load"]:
					rows.append(ROWS.action(_text.text("play." + intent, {"slot": slot}), {"intent": intent, "slot": "slot_%d" % slot, "number": slot}))
			rows.append(ROWS.action(_text.text("play.import"), {"intent": "import"}))
			rows.append(ROWS.action(_text.text("play.reduced_motion", {"value": _text.text("play.yes" if _data.get("reduced_motion", false) else "play.no")}), {"intent": "motion"}))
			rows.append(ROWS.action(_text.text("play.quality", {"value": _text.text("play.quality." + _data.get("quality", "high"))}), {"intent": "quality"}))
			rows.append(ROWS.action(_text.text("play.quit"), {"intent": "quit"}))
	if rows.is_empty():
		rows.append(ROWS.copy(_text.text("play.empty")))
	var tabs: Array = []
	for tab: Dictionary in _data.workspace.tabs:
		tabs.append({"id": tab.id, "text": _text.text(tab.text_key)})
	return {"title": _text.text("play." + section), "tabs": tabs, "rows": rows, "message": message, "close": _text.text("play.close")}


func begin_dialogue(id: String) -> bool:
	if not _graphs.has(id):
		return false
	graph_id = id
	node_id = "start"
	modal = "dialogue"
	return true


func dialogue() -> Dictionary:
	var node: Dictionary = _graphs[graph_id].nodes[node_id]
	var model := hud()
	var speaker_key := ""
	for person: Dictionary in _data.gameplay.roster:
		if person.id == node.speaker:
			speaker_key = person.name_key
	if speaker_key.is_empty():
		speaker_key = _graphs[graph_id].title_key
	model.speaker = _text.text(speaker_key)
	model.line = _text.text(node.text_key)
	model["continue"] = _text.text("ui.replica.dialogue.continue.1")
	model["foreground-note-copy"] = _text.text("ui.replica.dialogue.foreground_note.1")
	model.choices = []
	for choice: Dictionary in GRAPH.choices(node, _session.snapshot()):
		model.choices.append({"id": choice.id, "text": _text.text(choice.label_key)})
	return model


func advance(choice_id: String = "") -> bool:
	var node: Dictionary = _graphs[graph_id].nodes[node_id]
	var next: String = node.get("next", "")
	if node.has("choices"):
		var choices := GRAPH.choices(node, _session.snapshot())
		var matches: Array = choices.filter(func(c: Dictionary) -> bool: return c.id == choice_id)
		if matches.is_empty():
			return true
		var choice: Dictionary = matches[0]
		if choice.has("command") and not execute(choice.command).ok:
			return true
		next = choice.next
	if next.is_empty():
		modal = ""
		return false
	node_id = next
	return true


func option(key: String, value: Variant) -> void:
	_data[key] = value


func romance_confirmation(command: Dictionary) -> String:
	for person: Dictionary in _data.gameplay.roster:
		if person.id == command.get("person"):
			return _text.text("play.confirm_date", {"name": _text.text(person.name_key)})
	return _text.text("save.invalid")
