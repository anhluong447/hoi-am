extends RefCounted
## Builds side-room layer and prop nodes from authored room data and the art
## manifest. Image refs use injected textures; greybox refs draw flat rects.
## z bands: each plane has a fixed base; authored layer z is an offset within
## the plane, clamped to +-LAYER_SPREAD. Actors sit at ACTOR_Z; props stay in
## +-PROP_BAND around it (sort_y order), so no prop crosses a layer band.
## Parallax layers ignore Camera2D scrolling; scroll() drives them from the
## camera's world-space left edge so authored x aligns under any zoom.

const ACTOR_Z := 0
const PROP_BAND := 50
const LAYER_SPREAD := 40
const PLANE_Z := {"sky": -400, "far": -300, "back": -200, "mid": -100, "foreground": 200}


static func build(parent: Node2D, layers: Array, textures: Dictionary, manifest: Dictionary) -> void:
	for layer: Dictionary in layers:
		var node := art(str(layer.id), str(layer.art_ref), textures, manifest, Vector2.ZERO)
		node.position = _vector(layer.position)
		var scale := float(layer.scroll_scale)
		var z := layer_z(str(layer.plane), int(layer.z))
		if is_equal_approx(scale, 1.0):
			node.z_index = z
			parent.add_child(node)
			continue
		var parallax := Parallax2D.new()
		parallax.name = "Parallax_" + str(layer.id)
		parallax.scroll_scale = Vector2(scale, 1.0)
		parallax.ignore_camera_scroll = true
		parallax.z_index = z
		parallax.add_child(node)
		parent.add_child(parallax)


## Parallax2D places its content at (1 - scroll_scale) * screen_offset; feeding
## the camera's left edge relative to min_x keeps authored x exact at min_x.
static func scroll(parent: Node2D, camera_left: float, min_x: float) -> void:
	for child: Node in parent.get_children():
		if child is Parallax2D:
			child.screen_offset = Vector2(camera_left - min_x, 0.0)


## Visual children of layers flagged "water": true, for the water shader.
static func water_items(parent: Node2D, layers: Array) -> Array:
	var items: Array = []
	for layer: Dictionary in layers:
		if layer.get("water", false):
			items.append(parent.find_child(str(layer.id), true, false).get_child(0))
	return items


static func build_props(parent: Node2D, props: Array, textures: Dictionary, manifest: Dictionary, floor_y: float) -> void:
	var ordered := props.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.sort_y) < float(b.sort_y))
	for prop: Dictionary in ordered:
		var node := art(str(prop.id), str(prop.art_ref), textures, manifest, Vector2(0.5, 1.0))
		node.position = _vector(prop.position)
		node.z_index = prop_z(float(prop.sort_y), floor_y, bool(prop.occludes_actor))
		parent.add_child(node)


## Ties at the band edges keep sort_y order through build_props' tree order.
static func prop_z(sort_y: float, floor_y: float, occludes_actor: bool) -> int:
	var offset := roundi(clampf(sort_y - floor_y, -PROP_BAND, PROP_BAND))
	return ACTOR_Z + (clampi(offset, 1, PROP_BAND) if occludes_actor else clampi(offset, -PROP_BAND, -1))


static func layer_z(plane: String, z: int) -> int:
	return int(PLANE_Z[plane]) + clampi(z, -LAYER_SPREAD, LAYER_SPREAD)


static func art(id: String, ref: String, textures: Dictionary, manifest: Dictionary, default_pivot: Vector2) -> Node2D:
	var asset: Dictionary = manifest.assets[ref]
	var holder := Node2D.new()
	holder.name = id
	var size := _vector(asset.size)
	var pivot := default_pivot
	if asset.kind == "image":
		pivot = _vector(asset.pivot)
		var texture: Texture2D = textures.get(ref)
		if texture != null:
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.centered = false
			sprite.offset = -pivot * size
			sprite.scale = Vector2.ONE / float(asset.px_per_unit)
			holder.add_child(sprite)
			return holder
		size /= float(asset.px_per_unit)
	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color.html(str(asset.get("color", "#ff00ff")))
	rect.size = size
	rect.position = -pivot * size
	holder.add_child(rect)
	return holder


static func _vector(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1]))

