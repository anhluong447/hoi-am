extends Node
## One local clock owns foliage and bounded camera follow; no gameplay state.

var _props: Array[Node3D] = []
var _camera: Camera3D
var _player: CharacterBody3D
var _config: Dictionary
var _origin: Vector3
var _spawn: Vector3
var _offset := Vector3.ZERO
var _phase := 0.0


func configure(room: Node3D, config: Dictionary) -> void:
	_camera = room.camera
	_player = room.player
	_config = config.duplicate(true)
	_spawn = _player.position
	reset_camera()
	if room.has_node("Visuals"):
		for child: Node in room.get_node("Visuals").get_children():
			if child.has_meta("idle"):
				_props.append(child)
	set_process(not _config.is_empty())


func reset_camera() -> void:
	_origin = _camera.position
	_offset = Vector3.ZERO


func _process(delta: float) -> void:
	_phase += delta
	for prop: Node3D in _props:
		var idle: Dictionary = prop.get_meta("idle")
		prop.rotation.z = deg_to_rad(idle.degrees) * sin(_phase * TAU / idle.period + idle.phase)
	if not _config.has("follow"):
		return
	var follow: Dictionary = _config.follow
	var movement := _player.position - _spawn
	var goal := Vector3(clampf(movement.x * follow.strength[0], -follow.maximum[0], follow.maximum[0]), 0, clampf(movement.z * follow.strength[1], -follow.maximum[1], follow.maximum[1]))
	_offset = _offset.lerp(goal, 1.0 - exp(-delta / follow.response))
	_camera.position = _origin + _offset


func set_reduced(reduced: bool) -> void:
	set_process(not reduced and not _config.is_empty())
	if reduced:
		for prop: Node3D in _props:
			prop.rotation.z = 0.0
		_camera.position = _origin
		_offset = Vector3.ZERO
