extends RefCounted
## Probe each visible text/icon interior; paper alone cannot satisfy glyph presence.


static func choices_visible(bitmap: Image, view: Control) -> bool:
	for index: int in view._model.choices.size():
		if index >= view._choice_labels.size():
			break
		var label: Label = view._choice_labels[index]
		var region := Rect2i(label.get_rect()).intersection(Rect2i(0, 0, bitmap.get_width(), bitmap.get_height()))
		var color := label.get_theme_color("font_color")
		if _pixels(bitmap, region, color.g > 0.3) < maxi(20, label.text.length()):
			return false
		var bounds: Array = view._layout.choices[index].bounds
		if _pixels(bitmap, Rect2i(bounds[0] + 29, bounds[1] + 16, 28, 28), true) < 30:
			return false
	return true


static func _pixels(bitmap: Image, region: Rect2i, teal: bool) -> int:
	var count := 0
	for y: int in range(region.position.y, region.end.y):
		for x: int in range(region.position.x, region.end.x):
			var pixel := bitmap.get_pixel(x, y)
			if pixel.r < 0.3 and ((pixel.g > 0.3 and pixel.b > 0.3) if teal else (pixel.g < 0.3 and pixel.b < 0.4)):
				count += 1
	return count
