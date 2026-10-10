extends Control

var _profile: Dictionary = {"fill": "#122e39"}


func configure(profile: Dictionary) -> void:
	_profile = profile.duplicate(true)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(_profile.fill))
	if _profile.has("pattern"):
		var pattern: Dictionary = _profile.pattern
		var step: int = pattern.size
		for x: int in range(0, int(size.x), step):
			for y: int in range(0, int(size.y), step):
				var color := Color(pattern.colors[0])
				color.a = pattern.opacity
				draw_rect(Rect2(x, y, step / 2.0, step), color)
				color = Color(pattern.colors[1])
				color.a = pattern.opacity
				draw_line(Vector2(x, y), Vector2(x + step, y + step), color, 2)
				draw_line(Vector2(x + step, y), Vector2(x, y + step), color, 2)
