extends RefCounted
## Builds side-room layer and prop nodes from authored room data and the art
## manifest. Image refs use injected textures; greybox refs draw flat rects.
## Actors sort at ACTOR_Z; props sort by sort_y against floor_y around it.

const ACTOR_Z := 0
const PROP_Z_RANGE := 1000


static func build(parent: Node2D, layers: Array, textures: Dictionary, manifest: Dictionary) -> void:
	for layer: Dictionary in layers:
		var node := art(str(layer.id), str(layer.art_ref), textures, manifest, Vector2.ZERO)
		node.position = _vector(layer.position)
		var scale := float(layer.scroll_scale)
		if is_equal_approx(scale, 1.0):
			node.z_index = int(layer.z)
			parent.add_child(node)
			continue
		var parallax := Parallax2D.new()
		parallax.name = "Parallax_" + str(layer.id)
		parallax.scroll_scale = Vector2(scale, 1.0)
		parallax.z_index = int(layer.z)
		parallax.add_child(node)
		parent.add_child(parallax)


static func build_props(parent: Node2D, props: Array, textures: Dictionary, manifest: Dictionary, floor_y: float) -> void:
	for prop: Dictionary in props:
		var node := art(str(prop.id), str(prop.art_ref), textures, manifest, Vector2(0.5, 1.0))
		node.position = _vector(prop.position)
		node.z_index = prop_z(float(prop.sort_y), floor_y, bool(prop.occludes_actor))
		parent.add_child(node)


static func prop_z(sort_y: float, floor_y: float, occludes_actor: bool) -> int:
	var offset := clampi(roundi(sort_y - floor_y), -PROP_Z_RANGE, PROP_Z_RANGE)
	return ACTOR_Z + (maxi(offset, 1) if occludes_actor else mini(offset, -1))


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
