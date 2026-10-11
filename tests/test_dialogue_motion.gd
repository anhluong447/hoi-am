extends "res://tests/test_suite.gd"

const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const DIALOGUE = preload("res://src/presentation/coastal/dialogue_view.tscn")
const TEXT = preload("res://src/presentation/coastal/dialogue_text.gd")


func run() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var setup := STARTUP.prepare()
	var resources := STARTUP.ui_resources(setup.data)
	var model := STARTUP.fixture_model(setup.data.preview.dialogue, setup.text)
	var view := DIALOGUE.instantiate()
	view.configure(model, setup.data.dialogue_ui, resources)
	tree.root.add_child(view)
	var choices: Array = []
	var continued: Array = []
	var closed: Array = []
	view.choice_requested.connect(func(id: String) -> void: choices.append(id))
	view.continue_requested.connect(func() -> void: continued.append(true))
	view.closed.connect(func() -> void: closed.append(true))
	var paper: Control = view._layers.paper
	var notebook: Control = view._layers.notebook
	var hit_bounds: Rect2 = view._buttons[1].get_rect()
	view.present(false)
	expect(view._layers.paper.modulate.a == 0.0 and view._layers.flowers.modulate.a == 0.0, "Opening starts with separate hidden layers")
	for _frame: int in 5:
		await tree.process_frame
	expect(view._layers.wave.modulate.a > view._layers.paper.modulate.a and view._layers.flowers.modulate.a == 0.0, "Wave and paper lead delayed decoration")
	view._request_choice("draft")
	expect(choices.is_empty() and view._labels.line.visible, "First click reveals full sentence without issuing a choice")
	view._request_choice("draft")
	expect(choices.is_empty(), "Clicks during choice entrance cannot issue a command")
	for _frame: int in 24:
		await tree.process_frame
	view._choices.select(1)
	for _frame: int in 12:
		await tree.process_frame
	expect(view._choices._rows[1].scale.is_equal_approx(Vector2.ONE * setup.data.dialogue_ui.motion.choices.focus_scale), "Focused choice grows to authored scale")
	expect(view._choices._rows[0].scale.is_equal_approx(Vector2.ONE) and view._choices._rows[2].scale.is_equal_approx(Vector2.ONE), "Other choices settle at the same neutral scale")
	expect(view._buttons[1].get_rect() == hit_bounds, "Focus scaling never moves the hit target")
	view._choices.select(2)
	view._choices.select(0)
	for _frame: int in 12:
		await tree.process_frame
	expect(view._choices._rows[2].scale.is_equal_approx(Vector2.ONE), "Rapid focus changes cancel obsolete scale tweens")
	view._request_choice("draft")
	view._request_choice("draft")
	expect(choices == ["draft"], "One ready choice dispatches once even under rapid repeated input")
	var next := model.duplicate(true)
	next.choices = []
	next.line += "\n" + next.line
	next["foreground-note-copy"] = setup.text.text("ui.coastal.preview.note")
	view.transition(next)
	view.finish_reveal()
	expect(view.body_text() == next.line and view._state == "ready", "Skipping during line fade applies and completes the pending sentence")
	expect(view._layers.paper == paper and view._layers.notebook == notebook and paper.position == Vector2.ZERO, "Line changes retain paper and decorations")
	expect(view._labels["foreground-note-copy"].text == next["foreground-note-copy"], "Persistent notebook copy follows updated dialogue model")
	expect(view._reading._viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED, "Completed reveal stops the temporary glyph viewport")
	expect(view._reading._sharp.process_mode == Node.PROCESS_MODE_DISABLED and view._reading._soft.process_mode == Node.PROCESS_MODE_DISABLED, "Completed reveal disables internal rich-text effect processing")
	view._request_continue()
	view._request_continue()
	expect(continued.size() == 1, "Ready continuation emits once")
	view.transition(model)
	for _frame: int in 10:
		await tree.process_frame
	expect(view._reading.revealing and not view._labels.line.visible, "Changed sentence uses animated glyph passes")
	view.dismiss()
	view.dismiss()
	view._request_continue()
	expect(view.is_closing() and continued.size() == 1 and not view._labels.line.visible, "Closing freezes partial copy and blocks continuation")
	for _frame: int in 24:
		await tree.process_frame
	expect(closed.size() == 1 and paper.modulate.a == 0.0, "Reverse close completes exactly once")
	view.present(false)
	for _frame: int in 22:
		await tree.process_frame
	view.present(false)
	for _frame: int in 5:
		await tree.process_frame
	expect(view._state == "opening" and not view._reading.revealing and view._choices.buttons[0].disabled, "Replaying opening cancels previous text and choice callbacks")
	view.queue_free()
	await tree.process_frame
	await _reduced_and_schedule(tree, setup, resources, model)


func _reduced_and_schedule(tree: SceneTree, setup: Dictionary, resources: Dictionary, model: Dictionary) -> void:
	var view := DIALOGUE.instantiate()
	view.configure(model, setup.data.dialogue_ui, resources)
	tree.root.add_child(view)
	view.present(true)
	expect(view._state == "ready" and view._labels.line.visible, "Reduced motion reveals full copy and choices immediately")
	expect(not view._motion.is_processing() and not view._reading.is_processing(), "Reduced motion stops ambient and typewriter clocks")
	view._choices.select(2)
	expect(view._choices._rows[2].scale == Vector2.ONE, "Reduced motion keeps focused choice unscaled")
	var closed: Array = []
	view.closed.connect(func() -> void: closed.append(true))
	view.dismiss()
	expect(closed.size() == 1, "Reduced motion closes immediately")
	view.queue_free()
	await tree.process_frame
	var settings: Dictionary = setup.data.dialogue_ui.motion.typewriter
	var combined := String.chr(97) + String.chr(774) + String.chr(769)
	var schedule := TEXT.schedule(combined + ".x", settings)
	expect(schedule[0] == schedule[1] and schedule[1] == schedule[2], "Vietnamese combining marks share their base character arrival")
	expect(is_equal_approx(schedule[4] - schedule[3], 1.0 / settings.characters_per_second + settings.punctuation_pauses["."]), "Typewriter includes authored punctuation holds")
	for fps: int in [30, 60, 120]:
		view = DIALOGUE.instantiate()
		view.configure(model, setup.data.dialogue_ui, resources)
		tree.root.add_child(view)
		view._reading.start(false)
		var end: float = view._reading._end
		for _step: int in ceili(end * fps) + 1:
			view._reading._process(1.0 / fps)
		expect(not view._reading.revealing and view._labels.line.visible, "Reveal completion is frame-rate independent at " + str(fps))
		view.queue_free()
		await tree.process_frame
