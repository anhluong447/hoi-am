extends RefCounted
## Pure side-scroll motion math: speed ramp and bounds clamp. No Node, I/O,
## clock or ambient randomness; callers own all state.


static func step(velocity: float, axis: float, delta: float, tuning: Dictionary) -> float:
	var input_axis := axis
	if is_nan(input_axis):
		input_axis = 0.0
	input_axis = clampf(input_axis, -1.0, 1.0)
	var max_speed: float = tuning.max_speed
	var accel_time: float = tuning.accel_time
	var decel_time: float = tuning.decel_time
	var target := input_axis * max_speed
	var accelerating := velocity == 0.0 or (target != 0.0 and signf(target) == signf(velocity))
	var rate := (max_speed / accel_time) if accelerating else (max_speed / decel_time)
	return move_toward(velocity, target, rate * delta)


static func clamp_x(x: float, bounds: Dictionary, half_width: float) -> float:
	var value := x
	if is_nan(value):
		value = 0.0
	return clampf(value, bounds.min_x + half_width, bounds.max_x - half_width)
