extends "res://tests/test_suite.gd"

const V = preload("res://src/shared/side_room_validation.gd")


func _manifest() -> Dictionary:
	return {
		"schema_version": 1,
		"assets": {
			"greybox.wall": {"kind": "greybox", "color": "#8899aa", "size": [100.0, 200.0]},
			"image.desk": {
				"kind": "image",
				"path": "res://assets/world2d/desk.png",
				"size": [64.0, 32.0],
				"px_per_unit": 100.0,
				"pivot": [0.5, 1.0],
				"status": "placeholder_ai",
				"sha256": "a".repeat(64),
				"provenance": {"tool": "midjourney", "prompt_id": "desk-01", "date": "2026-10-28"},
			},
		},
	}


func _room() -> Dictionary:
	return {
		"kind": "side_room_v1",
		"id": "newsroom_side",
		"location_id": "newsroom",
		"title_key": "world2d.newsroom.title",
		"height": 1080,
		"bounds": {"min_x": 0.0, "max_x": 2000.0},
		"floor_y": 900.0,
		"default_spawn": "from_hall",
		"spawns": {"from_hall": {"x": 100.0, "facing": 1}},
		"layers": [
			{"id": "wall", "plane": "back", "scroll_scale": 0.5, "art_ref": "greybox.wall", "position": [0.0, 0.0], "z": 0},
		],
		"props": [
			{"id": "desk", "art_ref": "image.desk", "position": [300.0, 900.0], "sort_y": 900.0, "occludes_actor": false},
		],
		"doors": [
			{"id": "to_hall", "x": 50.0, "width": 80.0, "target_room": "hall_side", "target_spawn": "from_newsroom"},
		],
		"interactions": [
			{"id": "read_board", "x": 500.0, "width": 60.0, "label_key": "world2d.newsroom.board", "anchor_y": 880.0},
		],
		"actors": [
			{"id": "teacher", "actor_ref": "teacher", "x": 400.0, "facing": -1},
		],
		"lighting_ref": "newsroom_lighting",
	}


func _lighting() -> Dictionary:
	var phase := {
		"modulate": "#ffffff",
		"sun": {"color": "#ffeecc", "energy": 1.0, "angle": 45.0},
		"lights": [{"id": "lamp", "position": [10.0, 10.0], "color": "#ffffff", "energy": 1.0, "radius": 50.0}],
		"dust": 0.2,
		"water_tint": "#223344",
	}
	return {
		"schema_version": 1,
		"phases": {"sang": phase, "chieu": phase, "toi": phase, "dem": phase},
	}


func run() -> void:
	var manifest := _manifest()
	var room := _room()
	expect(V.validate_room(room, manifest).ok, "Valid side room accepted")

	var bad: Dictionary = room.duplicate(true)
	bad.kind = "wrong"
	expect(not V.validate_room(bad, manifest).ok, "Wrong kind rejected")

	bad = room.duplicate(true)
	bad.bounds = {"min_x": 10.0, "max_x": 10.0}
	expect(not V.validate_room(bad, manifest).ok, "min_x >= max_x rejected")

	bad = room.duplicate(true)
	bad.spawns = {"from_hall": {"x": 9999.0, "facing": 1}}
	expect(not V.validate_room(bad, manifest).ok, "Spawn x outside bounds rejected")

	bad = room.duplicate(true)
	bad.spawns = {"from_hall": {"x": NAN, "facing": 1}}
	expect(not V.validate_room(bad, manifest).ok, "Spawn x NAN rejected")

	bad = room.duplicate(true)
	bad.default_spawn = "missing_spawn"
	expect(not V.validate_room(bad, manifest).ok, "default_spawn not in spawns rejected")

	bad = room.duplicate(true)
	bad.layers[0].art_ref = "missing_asset"
	expect(not V.validate_room(bad, manifest).ok, "Unresolved art_ref rejected")

	bad = room.duplicate(true)
	bad.props[0].id = "wall"
	expect(not V.validate_room(bad, manifest).ok, "Duplicate id across layers/props rejected")

	bad = room.duplicate(true)
	bad.layers[0].plane = "midground"
	expect(not V.validate_room(bad, manifest).ok, "Unknown plane rejected")

	bad = room.duplicate(true)
	bad.doors[0].erase("target_spawn")
	expect(not V.validate_room(bad, manifest).ok, "Door missing target_spawn rejected")

	expect(V.validate_manifest(manifest).ok, "Valid manifest accepted")

	var bad_manifest: Dictionary = manifest.duplicate(true)
	bad_manifest.assets["image.desk"].erase("sha256")
	expect(not V.validate_manifest(bad_manifest).ok, "Image missing sha256 rejected")

	bad_manifest = manifest.duplicate(true)
	bad_manifest.assets["image.desk"].erase("status")
	expect(not V.validate_manifest(bad_manifest).ok, "Image missing status rejected")

	bad_manifest = manifest.duplicate(true)
	bad_manifest.assets["image.desk"].px_per_unit = 0.0
	expect(not V.validate_manifest(bad_manifest).ok, "px_per_unit <= 0 rejected")

	bad_manifest = manifest.duplicate(true)
	bad_manifest.assets["greybox.wall"].color = "blue"
	expect(not V.validate_manifest(bad_manifest).ok, "Malformed greybox color rejected")

	var lighting := _lighting()
	expect(V.validate_lighting(lighting).ok, "Valid lighting preset accepted")

	var bad_lighting: Dictionary = lighting.duplicate(true)
	bad_lighting.phases.erase("dem")
	expect(not V.validate_lighting(bad_lighting).ok, "Missing lighting phase rejected")

	bad_lighting = lighting.duplicate(true)
	bad_lighting.phases.sang = bad_lighting.phases.sang.duplicate(true)
	bad_lighting.phases.sang.dust = 1.5
	expect(not V.validate_lighting(bad_lighting).ok, "dust outside 0..1 rejected")
