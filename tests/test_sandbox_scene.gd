extends "res://tests/test_suite.gd"

const SCENE = preload("res://src/bootstrap/sandbox/sandbox.tscn")


func run() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var sandbox := SCENE.instantiate()
	tree.root.add_child(sandbox)
	await tree.process_frame
	expect(sandbox._view.get_child_count() == 2 and sandbox._session.is_ready(), "Sandbox scene mounts configured tool UI and real session")
	sandbox._command({"type": "debug", "patch": {"pressure": 200}})
	expect(sandbox._session.snapshot().pressure == 200, "Sandbox authored debug uses session")
	sandbox._command({"type": "auto_day"})
	expect(sandbox._session.snapshot().day == 2, "Sandbox single-day command renders journal-bearing state")
	sandbox._command({"type": "reset"})
	expect(sandbox._session.snapshot().day == 1 and sandbox._session.snapshot().pressure == 0, "Sandbox reset is explicit")
	await sandbox._command({"type": "benchmark", "id": "balanced"})
	expect(sandbox._session.snapshot().outcome == "win" and not sandbox._busy and sandbox._results.size() == 1, "Sandbox native view renders actual completed benchmark")
	sandbox.queue_free()
	await tree.process_frame
