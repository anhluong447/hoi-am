extends "res://tests/test_suite.gd"

const PREVIEW = preload("res://src/bootstrap/previews/ui_preview.tscn")
const CALENDAR = preload("res://src/bootstrap/previews/calendar_preview.tscn")


func run() -> void:
	var tree: SceneTree = Engine.get_main_loop()
	var preview := PREVIEW.instantiate()
	tree.root.add_child(preview)
	await tree.process_frame
	expect(not preview.view.body_text().is_empty(), "Dialogue resolves authored Vietnamese copy")
	var model: Dictionary = preview.view._model.duplicate(true)
	model.line += "\n" + model.line
	preview.view.configure(model, preview.view._layout, preview.view._resources)
	expect(preview.view.body_text().contains("\n"), "Dialogue preserves model line breaks")
	var buttons: Array = preview.view._buttons
	expect(buttons.size() == 4, "Three choice targets and continue")
	expect(buttons[0].has_focus(), "Keyboard focus starts on first choice")
	var choices: Array = []
	preview.view.choice_requested.connect(func(id: String) -> void: choices.append(id))
	buttons[1].pressed.emit()
	expect(choices == ["draft"], "Choice signal carries ID independent of label")
	await tree.process_frame
	var before: Vector2 = preview.view._buttons[0].position
	for background: String in ["neutral", "ui-light", "ui-dark", "ui-detail"]:
		preview.show_case("dialogue", background, true)
		await tree.process_frame
		expect(preview.view._buttons[0].position == before, "Backdrop preserves native hit target: " + background)
		expect(not preview.toolbar.visible, "Capture hides authoring controls: " + background)
	preview.show_case("hud", "ui-detail", true)
	await tree.process_frame
	preview.view.show_prompt("resolved fixture", {"visible": false})
	expect(not preview.view._prompt.visible, "Occluded/offscreen prompt hidden")
	preview.view.show_prompt("resolved fixture", {"visible": true, "position": Vector2(500, 300)})
	expect(preview.view._prompt.visible, "Visible world anchor prompt")
	preview.queue_free()
	await tree.process_frame
	var calendar := CALENDAR.instantiate()
	tree.root.add_child(calendar)
	await tree.process_frame
	expect(calendar.session.is_ready(), "Calendar preview owns a real validated session")
	calendar._command({"type": "school"})
	expect(calendar.session.snapshot().phase == "club" and calendar._hud._labels.energy.text.contains("4"), "Command refreshes HUD from live state")
	var state: Dictionary = calendar.session.snapshot()
	calendar._command({"type": "sleep"})
	expect(calendar.session.snapshot() == state and not calendar._panel._message.text.is_empty(), "Rejected command shows catalog error and preserves state")
	calendar.queue_free()
	await tree.process_frame
