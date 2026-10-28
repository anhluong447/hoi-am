extends "res://tests/test_suite.gd"

const ROOM = preload("res://src/world/side/side_room.tscn")
const LIGHTING = preload("res://src/world/side/side_lighting.gd")
const V = preload("res://src/shared/side_room_validation.gd")
const LOADER = preload("res://src/infrastructure/content/json_content_loader.gd")
const PLAYABLE = preload("res://src/bootstrap/gameplay/playable.tscn")
const PRESETS := ["school_day", "room3", "home"]
const REPORT := "res://docs/world-side/evidence/e1-stress-v1/report.json"


func _content(path: String) -> Dictionary:
	var loaded := LOADER.read_dictionary(path)
	expect(loaded.ok, "Content loads: %s" % path)
	return loaded.get("data", {})


func _room(lighting: Dictionary, phase_map: Dictionary) -> Dictionary:
	return {
		"kind": "side_room_v1",
		"id": "harbor_2d",
		"location_id": "harbor",
		"title_key": "ui.common.quit",
		"height": 1080.0,
		"bounds": {"min_x": 0.0, "max_x": 3000.0},
		"floor_y": 900.0,
		"default_spawn": "left",
		"spawns": {"left": {"x": 400.0, "facing": 1}},
		"layers": [
			{"id": "sky", "plane": "sky", "scroll_scale": 0.3, "art_ref": "greybox.sky", "position": [0.0, 0.0], "z": 0},
			{"id": "sea", "plane": "far", "scroll_scale": 0.5, "art_ref": "greybox.sky", "position": [0.0, 600.0], "z": 0, "water": true},
		],
		"props": [],
		"doors": [],
		"interactions": [],
		"actors": [],
		"lighting_ref": "school_day",
		"manifest": {"schema_version": 1, "assets": {"greybox.sky": {"kind": "greybox", "color": "#8fb4d8", "size": [3000.0, 600.0]}}},
		"tuning": {
			"max_speed": 360.0, "accel_time": 0.10, "decel_time": 0.08, "stride": 180.0, "bob": 4.0,
			"camera_dead_zone": 120.0, "camera_response": 0.08, "actor_height": 300.0, "actor_half_width": 40.0,
		},
		"lighting": lighting,
		"phase_map": phase_map,
	}


func _mount(config: Dictionary, reduced: bool) -> Node:
	var room := ROOM.instantiate()
	if reduced:
		room.set_reduced_motion(true)
	room.configure(config, {}, {})
	Engine.get_main_loop().root.add_child(room)
	return room


func _frames(count: int) -> void:
	for _frame: int in count:
		await Engine.get_main_loop().process_frame


func _lights(room: Node) -> Array[Node]:
	return room.find_children("*", "PointLight2D", true, false)


func _near(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.01 and absf(a.g - b.g) < 0.01 and absf(a.b - b.b) < 0.01


func _check_content(phase_map: Dictionary) -> void:
	expect(phase_map == {"morning": "sang", "club": "chieu", "investigation": "chieu", "personal": "chieu", "evening": "toi", "bed": "dem", "weekend1": "sang", "weekend2": "chieu"}, "Phase map matches the authored domain mapping")
	for id: String in PRESETS:
		var preset := _content("res://content/world2d/lighting/%s.json" % id)
		expect(V.validate_lighting(preset).ok, "Lighting preset %s validates" % id)
		for domain_phase: String in phase_map:
			expect(preset.get("phases", {}).has(phase_map[domain_phase]), "Preset %s has phase for %s" % [id, domain_phase])
	var phase := {"modulate": "#ffffff", "sun": {"color": "#ffffff", "energy": 1.0, "angle": 0.0}, "dust": 0.0, "water_tint": "#ffffff", "lights": []}
	for index: int in 3:
		phase.lights.append({"id": "l%d" % index, "position": [0.0, 0.0], "color": "#ffffff", "energy": 1.0, "radius": 10.0})
	var crowded := {"schema_version": 1, "phases": {"sang": phase, "chieu": phase, "toi": phase, "dem": phase}}
	expect(not V.validate_lighting(crowded).ok, "Validator rejects more runtime lights than the cap")
	crowded.phases = {"sang": {}, "chieu": {}, "toi": {}, "dem": {}}
	crowded.schema_version = 1.5
	expect(V.validate_lighting(crowded).errors.has("lighting.schema_version must be an int"), "Non-integral schema_version rejected")
	var report: Variant = JSON.parse_string(FileAccess.get_file_as_string(REPORT))
	expect(report is Dictionary and LIGHTING.MAX_RUNTIME_LIGHTS <= int(report.recommendation.max_runtime_lights), "Runtime light cap honours the E1 recommendation")
	var lighting := LIGHTING.new()
	lighting.configure({"min_x": 0.0, "max_x": 100.0}, 100.0, [])
	lighting.apply(phase, 1.0)
	expect(lighting.find_children("*", "PointLight2D", true, false).size() <= LIGHTING.MAX_RUNTIME_LIGHTS, "Excess preset lights are ignored at runtime")
	lighting.free()
	var room := {"layers": [{"id": "sea", "plane": "far", "scroll_scale": 0.5, "art_ref": "a", "position": [0.0, 0.0], "z": 0, "water": "yes"}]}
	expect(V.validate_room(room, {"assets": {"a": {}}}).errors.has("Layer sea water must be a bool"), "Validator rejects a non-bool water flag")


func run() -> void:
	var phase_map := _content("res://content/world2d/phase_lighting.json")
	var preset := _content("res://content/world2d/lighting/room3.json")
	_check_content(phase_map)
	var toi := Color.html(str(preset.phases.toi.modulate))

	var room := _mount(_room(preset, phase_map), false)
	await _frames(2)
	var modulate: CanvasModulate = room.find_children("*", "CanvasModulate", true, false)[0]
	expect(_near(modulate.color, Color.html(str(preset.phases.sang.modulate))), "Room mounts on the default morning light")
	room.set_lighting_phase("evening")
	await _frames(2)
	expect(not _near(modulate.color, toi), "Phase change tweens instead of snapping")
	room.lighting.tween.custom_step(2.0)
	expect(_near(modulate.color, toi), "Evening tween settles on toi.modulate")
	room.set_lighting_phase("bed")
	room.lighting.tween.custom_step(2.0)
	expect(_lights(room).size() <= LIGHTING.MAX_RUNTIME_LIGHTS and _lights(room).size() > 0, "Night lamps mount within the runtime cap")
	var grade: CanvasLayer = room.find_child("Grade", true, false)
	var ui: Node = PLAYABLE.instantiate()
	expect(grade != null and ui.get_node("Interface").layer > grade.layer, "Coastal UI layer sits above the grade layer")
	ui.free()
	expect(grade.get_child(0).material.shader.resource_path.ends_with("side_grade.gdshader"), "Grade uses side_grade shader")
	var dust: CPUParticles2D = room.find_children("*", "CPUParticles2D", true, false)[0]
	expect(dust.use_fixed_seed and dust.seed == hash("harbor_2d"), "Dust seed derives from the room id")
	room.set_lighting_phase("investigation")
	room.lighting.tween.custom_step(2.0)
	expect(dust.emitting and dust.amount == roundi(float(preset.phases.chieu.dust) * 120.0), "Dust density scales the particle count")
	var sea: CanvasItem = room.find_child("sea", true, false).get_child(0)
	expect(sea.material is ShaderMaterial and sea.material.shader.resource_path.ends_with("side_water.gdshader"), "Water layer gets the water shader")
	room.set_quality("low")
	expect(not dust.emitting and sea.material == null and not room.lighting.animated, "Low quality: dust off, static water tint, static shaft")
	expect(grade.visible, "Low quality keeps the grade")
	room.set_quality("high")
	expect(dust.emitting and sea.material is ShaderMaterial and room.lighting.animated, "High quality restores dust, water shader and shaft motion")
	room.set_lighting_phase("unknown_phase")
	expect(not room.lighting.is_transitioning(), "Unmapped phase keeps the current light")
	room.queue_free()
	await _frames(1)

	room = _mount(_room(preset, phase_map), true)
	await _frames(2)
	dust = room.find_children("*", "CPUParticles2D", true, false)[0]
	expect(not dust.emitting, "Reduced motion before configure keeps particles off at mount")
	expect(not room.lighting.animated, "Reduced motion before configure keeps the shaft static")
	room.place_player("left", 1500.0)
	room.player.position.x = 2200.0
	await Engine.get_main_loop().physics_frame
	await Engine.get_main_loop().physics_frame
	expect(is_equal_approx(room.camera.position.x, 2200.0), "Reduced motion camera snaps to the player")
	room.set_lighting_phase("evening")
	modulate = room.find_children("*", "CanvasModulate", true, false)[0]
	expect(_near(modulate.color, toi), "Reduced motion applies the phase immediately")
	room.queue_free()
	await _frames(1)
