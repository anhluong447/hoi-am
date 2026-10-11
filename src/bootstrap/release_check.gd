extends Node
## Explicit CLI packaging check; writes only to isolated developer save directory.

const DATA = preload("res://src/shared/json_data.gd")

var _failures: Array[String] = []

const PLAY = preload("res://src/bootstrap/gameplay/playable.tscn")
const STORE = preload("res://src/infrastructure/saves/file_save_store.gd")
const SAVES = preload("res://src/application/gameplay_saves.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")


func run() -> void:
	var play := PLAY.instantiate()
	add_child(play)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var initial: Dictionary = play.setup.session.snapshot()
	_expect(play.room.has_node("Visuals"), "Packaged selected HD-2D newsroom art")
	_expect(play.room.get_node("Visuals/club-sign").text == play.setup.text.text("world.newsroom.sign"), "Packaged live world sign")
	for version: String in ["v1", "v2"]:
		_expect(not FileAccess.file_exists("res://assets/world/coastal/" + version + "/source/prompts.json"), "Art source prompts excluded from package")
		for stem: String in ["props", "surfaces", "harbor", "companion", "outdoor"]:
			_expect(not FileAccess.file_exists("res://assets/world/coastal/" + version + "/source/" + stem + ".png"), "Raw art masters excluded from package")
	play.interact("van")
	play._advance("school")
	play._advance()
	_expect(play.setup.session.snapshot().phase == "club", "Packaged integrated command")
	var state: Dictionary = play.setup.session.snapshot()
	for section: String in ["cases", "quests", "team", "editorial", "life", "travel", "reports", "saves"]:
		play.controller.section = section
		play.open_workspace()
		await get_tree().process_frame
	play.close_modal()
	var store := STORE.new("user://release_checks/gameplay")
	var saves := SAVES.new(play.setup.session, play.setup.data.gameplay, store.read_slot, store.write_slot, play.setup.validator.validate)
	_expect(saves.save("slot_1", play.world_snapshot(), "release-check").ok, "Packaged user save writes")
	play.setup.session.replace(initial)
	_expect(saves.load_slot("slot_1").ok and DATA.equivalent(play.setup.session.snapshot(), state), "Packaged load round-trip")
	_expect(not saves.import_payload({"kind": "hoi-am-save", "envelope_version": 1, "ruleset": "formula_sandbox"}).ok and DATA.equivalent(play.setup.session.snapshot(), state), "Packaged load rejects wrong ruleset")
	_expect(LOADER.read_dictionary("res://content/formula_sandbox/pack.json").ok, "Packaged formula JSON included")
	var font: Font = load("res://assets/fonts/source_serif_4/source-serif-4.ttf")
	for codepoint: int in [0x1ed3, 0x1ec1, 0x1ea3, 0x1ef9, 0x0111]:
		_expect(font.has_char(codepoint), "Vietnamese glyph packaged")
	for location: String in ["school", "library", "cafe", "shop", "job", "waterfront", "home", "club"]:
		play.travel(location)
		await get_tree().physics_frame
		await get_tree().physics_frame
		_expect(play.controller.location_id == location and play.room.has_node("Visuals"), "Packaged selected HD-2D location")
	play.travel("library")
	await get_tree().physics_frame
	var capture: PackedStringArray = OS.get_cmdline_user_args()
	if capture.has("--capture"):
		await RenderingServer.frame_post_draw
		var dir := "user://release_checks"
		DirAccess.make_dir_recursive_absolute(dir)
		get_viewport().get_texture().get_image().save_png(dir.path_join("native-build.png"))
	play.queue_free()
	await get_tree().process_frame
	var sandbox := preload("res://src/bootstrap/sandbox/sandbox.tscn").instantiate()
	add_child(sandbox)
	await sandbox._command({"type": "benchmark", "id": "balanced"})
	_expect(sandbox._session.snapshot().outcome == "win", "Packaged sandbox benchmark and UI")
	for failure: String in _failures:
		push_error(failure)
	print("Release checks: packaged gameplay, management, save/load, ruleset isolation, formula content, font glyphs, room travel passed")
	get_tree().quit(0 if _failures.is_empty() else 1)


func _expect(condition: bool, diagnostic: String) -> void:
	if not condition:
		_failures.append(diagnostic)
