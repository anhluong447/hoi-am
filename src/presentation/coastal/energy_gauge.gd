extends Control
## Renderer-only energy dots; capacity and current value arrive in the view model.

var _spec: Dictionary
var _value := 0
var _capacity := 0


func configure(spec: Dictionary, value: int, capacity: int) -> void:
	_spec = spec.duplicate(true)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_value(value, capacity)


func update_value(value: int, capacity: int) -> void:
	_capacity = clampi(capacity, 0, _spec.centers.size())
	_value = clampi(value, 0, _capacity)
	queue_redraw()


func _draw() -> void:
	for index: int in _capacity:
		var point := Vector2(_spec.centers[index][0], _spec.centers[index][1])
		if index < _value:
			draw_circle(point, _spec.radius, Color(_spec.filled), true, -1, true)
		else:
			draw_circle(point, _spec.radius, Color(_spec.empty), true, -1, true)
			draw_circle(point, _spec.radius, Color(_spec.outline), false, _spec.width, true)
