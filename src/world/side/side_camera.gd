extends Camera2D
## Side-scroll follow camera: maps room height to the viewport, clamps to
## room bounds and eases toward the tracked actor with a dead zone.

var _bounds := {}
var _dead_zone := 0.0
var _response := 0.0


func configure(bounds: Dictionary, height: float, tuning: Dictionary) -> void:
	_bounds = bounds.duplicate(true)
	_dead_zone = tuning.get("camera_dead_zone", 0.0)
	_response = tuning.get("camera_response", 0.0)
	limit_left = int(_bounds.min_x)
	limit_right = int(_bounds.max_x)
	limit_top = 0
	limit_bottom = int(height)
	position.y = height / 2.0
	var viewport_height := get_viewport_rect().size.y
	var factor := viewport_height / height
	zoom = Vector2(factor, factor)


func follow(target_x: float, delta: float, reduced: bool) -> void:
	var clamped_target := clampf(target_x, _bounds.min_x, _bounds.max_x)
	if reduced:
		position.x = clamped_target
		return
	if absf(clamped_target - position.x) > _dead_zone:
		var rate := 1.0 - pow(1.0 - _response, delta * 60.0)
		position.x = lerpf(position.x, clamped_target, rate)
	position.x = clampf(position.x, _bounds.min_x, _bounds.max_x)


func snap(target_x: float) -> void:
	position.x = clampf(target_x, _bounds.min_x, _bounds.max_x)
