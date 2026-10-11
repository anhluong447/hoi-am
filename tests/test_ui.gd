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
	preview.view.show_prompt("resolved fixture", {"visible": true, "position": Vector2(2, 2)})
	await tree.process_frame
	expect(preview.view._prompt_box.position.x >= 12 and preview.view._prompt_box.position.y >= 12, "Prompt stays inside viewport at extreme anchor")
	model = preview.view._model.duplicate(true)
	model.money = preview._setup.text.text("ui.hud.money", {"money": {"number": 1000000000, "format": "vi_integer"}})
	model.energy_value = 1
	model.energy_capacity = 2
	preview.view.render(model)
	await tree.process_frame
	var money: Label = preview.view._labels.money
	var font_size := money.get_theme_font_size("font_size")
	expect(money.get_theme_font("font").get_string_size(money.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= preview.view._layout.text[3].width, "Large Vietnamese currency fits resource ribbon without truncation")
	expect(preview.view._gauge._value == 1 and preview.view._gauge._capacity == 2, "Energy dots update from current view model")
	preview.show_case("dialogue", "ui-dark", true)
	model = preview.view._model.duplicate(true)
	model.choices[0].text = preview._setup.text.text("ui.review.long_choice")
	preview.view.configure(model, preview.view._layout, preview.view._resources)
	await tree.process_frame
	expect(preview.view._buttons[0].get_rect().encloses(preview.view._choice_labels[0].get_rect()), "Wrapped Vietnamese choice copy stays within original hit target")
	expect(preview.view._choice_labels[0].text == model.choices[0].text, "Long choice keeps full source copy and stable ID")
	var selected_font: FontVariation = preview.view._choice_labels[0].get_theme_font("font")
	expect(selected_font.variation_opentype.wght == preview.view._layout.choice_copy.selected.weight, "Initial selected choice uses authored weight")
	preview.view._buttons[1].grab_focus()
	await tree.process_frame
	expect(preview.view._choice_labels[1].get_theme_color("font_color") == Color(preview.view._layout.choice_copy.selected.fill), "Keyboard focus applies selected ink to current choice")
	expect(preview.view._choice_labels[0].get_theme_font("font").variation_opentype.wght == preview.view._layout.choices[0].font.weight, "Previous choice returns to authored idle weight")
	expect(selected_font.variation_opentype.wght == preview.view._layout.choice_copy.selected.weight, "Focus switches stable font resources without mutating selected variation")
	expect(preview.view._buttons[0].get_rect().encloses(preview.view._choice_labels[0].get_rect()), "Long copy stays in target after selection changes weight")
	model.selected_choice = "draft"
	model.focus = true
	preview.view.configure(model, preview.view._layout, preview.view._resources)
	await tree.process_frame
	expect(preview.view._buttons[1].has_focus() and preview.view._choice_mark[1].visible, "Reconfiguration focuses the authored selected choice instead of resetting to first")
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
