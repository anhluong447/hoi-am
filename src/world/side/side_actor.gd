extends Node2D
## Side-scroll actor: holds motion/bob state and the placeholder or authored
## visual. Reads no input; the room calls move()/stop() each frame.
const MOTION = preload("res://src/world/side/side_motion.gd")

var velocity := 0.0
var facing := 1
var travelled := 0.0

var _tuning := {}
var _visual: Node2D


func configure(texture: Texture2D, height_ref: float, tuning: Dictionary) -> void:
	_tuning = tuning.duplicate(true)
	velocity = 0.0
	travelled = 0.0
	facing = 1
	if _visual != null:
		_visual.queue_free()
		_visual = null
	if texture != null:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = true
		sprite.offset = Vector2(0.0, -height_ref / 2.0)
		_visual = sprite
	else:
		var half_width: float = _tuning.get("actor_half_width", height_ref * 0.13)
		var silhouette := Polygon2D.new()
		silhouette.color = Color(0.15, 0.17, 0.22)
		silhouette.polygon = PackedVector2Array([
			Vector2(-half_width, 0.0),
			Vector2(half_width, 0.0),
			Vector2(half_width, -height_ref),
			Vector2(-half_width, -height_ref),
		])
		_visual = silhouette
	add_child(_visual)


func move(axis: float, delta: float, bounds: Dictionary) -> void:
	velocity = MOTION.step(velocity, axis, delta, _tuning)
	var half_width: float = _tuning.get("actor_half_width", 40.0)
	var tentative := position.x + velocity * delta
	var clamped := MOTION.clamp_x(tentative, bounds, half_width)
	var moved := clamped - position.x
	if not is_equal_approx(clamped, tentative):
		velocity = 0.0
	position.x = clamped
	travelled += absf(moved)
	if not is_zero_approx(velocity):
		facing = 1 if velocity > 0.0 else -1
		if _visual != null:
			_visual.scale.x = absf(_visual.scale.x) * float(facing)
	var stride: float = _tuning.get("stride", 180.0)
	var bob: float = _tuning.get("bob", 0.0)
	if _visual != null and stride > 0.0:
		_visual.position.y = sin(travelled / stride * TAU) * bob


func stop() -> void:
	velocity = 0.0
