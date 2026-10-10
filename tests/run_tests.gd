extends SceneTree

const TEXT_TESTS = preload("res://tests/test_text_catalog.gd")
const SESSION_TESTS = preload("res://tests/test_game_session.gd")
const SUITE = preload("res://tests/test_suite.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const CATALOG = preload("res://src/shared/text_catalog.gd")
const MAIN = preload("res://src/bootstrap/main.tscn")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var count := 0
	for suite: RefCounted in [TEXT_TESTS.new(), SESSION_TESTS.new()]:
		suite.run()
		count += suite.checks
		failures.append_array(suite.failures)
	var smoke := SUITE.new()
	var catalog := CATALOG.new()
	var loaded := LOADER.read_dictionary("res://content/locales/vi.json")
	smoke.expect(loaded["ok"], "Shipped locale must load")
	if loaded["ok"]:
		catalog.set_catalog(loaded["data"])
		var main := MAIN.instantiate()
		root.add_child(main)
		await process_frame
		var view := main.get_node_or_null("Interface/BootstrapView")
		smoke.expect(view != null, "Bootstrap must mount its view")
		if view != null:
			var title: Label = view.get_node("Center/Content/Title")
			smoke.expect(title.text == catalog.format_text("ui.coastal.title")["text"], "Title from catalog")
			smoke.expect(root.title == title.text, "Window title from catalog")
		main.queue_free()
		await process_frame
	smoke.expect(not LOADER.read_dictionary("res://project.godot")["ok"], "Loader restricts content root")
	smoke.expect(not LOADER.read_dictionary("res://content/../project.godot")["ok"], "Reject content traversal")
	smoke.expect(not LOADER.read_dictionary("res://content/missing.json")["ok"], "Missing content fails")
	count += smoke.checks
	failures.append_array(smoke.failures)
	for failure: String in failures:
		push_error(failure)
	print("Headless contracts: %d checks; %d failures" % [count, failures.size()])
	quit(0 if failures.is_empty() else 1)
