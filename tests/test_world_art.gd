extends "res://tests/test_suite.gd"

const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const VALIDATION = preload("res://src/shared/world_art_validation.gd")
const RESOURCES = preload("res://src/bootstrap/world_resources.gd")
const STARTUP = preload("res://src/bootstrap/project_startup.gd")
const ROOM = preload("res://src/world/rooms/newsroom/newsroom.tscn")


func run() -> void:
	var manifest: Dictionary = LOADER.read_dictionary("res://content/world/art_manifest_v1.json").data
	var visual: Dictionary = LOADER.read_dictionary("res://content/world/visuals/prop_slice_v1.json").data
	expect(VALIDATION.validate(manifest, visual), "Original prop regions and spatial layers validate")
	expect(not VALIDATION.validate({}, visual), "Incomplete world manifest fails without a script error")
	var bad: Dictionary = manifest.duplicate(true)
	bad.assets[0].region = [0, 0, 99999, 100]
	expect(not VALIDATION.validate(bad, visual), "Outside atlas region rejected")
	bad = manifest.duplicate(true)
	bad.atlases[0].texture_path = "res://assets/world/../actors/khue.png"
	expect(not VALIDATION.validate(bad, visual), "World asset traversal rejected")
	var malformed: Dictionary = visual.duplicate(true)
	malformed.props[0].position[0] = NAN
	expect(not VALIDATION.validate(manifest, malformed), "Nonfinite prop placement rejected")
	malformed = visual.duplicate(true)
	malformed.props[0].layers[0].asset = "missing"
	expect(not VALIDATION.validate(manifest, malformed), "Unresolved prop art rejected")
	var config: Dictionary = LOADER.read_dictionary("res://content/world/newsroom_hd2d_prop_slice.json").data
	var original: Dictionary = config.duplicate(true)
	var setup := STARTUP.prepare()
	var prepared := RESOURCES.prepare(config, STARTUP.actor_textures(setup.data))
	expect(prepared.ok and config == original and not config.has("visuals"), "Resource composition does not mutate authored room input")
	var room := ROOM.instantiate()
	room.configure(prepared.config, setup.data.actors.actors, prepared.textures)
	Engine.get_main_loop().root.add_child(room)
	for _frame: int in 8:
		await Engine.get_main_loop().physics_frame
	expect(room.get_node("Visuals/desk-visual").layers[0].alpha_cut == SpriteBase3D.ALPHA_CUT_DISCARD, "Prop cutout participates in depth without blended sorting")
	expect(room.get_node("Geometry/writing-desk").get_child(0).cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY, "Legacy solid shape becomes an invisible shadow proxy")
	expect(room.get_node("Geometry/writing-desk").get_child_count() == 2, "Replacing artwork retains table collision")
	room.queue_free()
	await Engine.get_main_loop().process_frame
