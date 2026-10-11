extends RichTextEffect
## Two glyph passes crossfade from a genuinely blurred tail into crisp text.

var bbcode := "dialogue_ink"
var clock := 0.0
var arrivals := PackedFloat32Array()
var duration := 0.0
var soft := false


func _process_custom_fx(glyph: CharFXTransform) -> bool:
	var index := glyph.range.x
	if index < 0 or index >= arrivals.size():
		glyph.visible = false
		return true
	var age := clock - arrivals[index]
	if age < 0.0:
		glyph.visible = false
		return true
	var maturity := smoothstep(0.0, duration, age)
	glyph.color.a *= 1.0 - maturity if soft else maturity
	glyph.visible = glyph.color.a > 0.0
	return true
