extends RefCounted
## Pure authored visual contract; file loading and resource creation stay outside.


static func validate(manifest: Dictionary, visual: Dictionary) -> bool:
	if not manifest.get("atlases") is Array or not manifest.get("assets") is Array or not visual.get("props", []) is Array:
		return false
	var atlases: Dictionary = {}
	for value: Variant in manifest.atlases:
		if not value is Dictionary or not _id(value.get("id")) or not value.get("texture_path") is String or not _numbers(value.get("size"), 2):
			return false
		var atlas: Dictionary = value
		if atlases.has(atlas.id) or not atlas.texture_path.begins_with("res://assets/world/") or atlas.texture_path.contains(".."):
			return false
		if not _numbers(atlas.size, 2) or atlas.size[0] <= 0 or atlas.size[1] <= 0:
			return false
		atlases[atlas.id] = atlas
	var assets: Dictionary = {}
	for value: Variant in manifest.assets:
		if not value is Dictionary or not _id(value.get("id")) or not _numbers(value.get("region"), 4):
			return false
		var asset: Dictionary = value
		if assets.has(asset.id) or not atlases.has(asset.get("atlas")):
			return false
		var rectangle := Rect2(asset.region[0], asset.region[1], asset.region[2], asset.region[3])
		var bounds := Rect2(Vector2.ZERO, Vector2(atlases[asset.atlas].size[0], atlases[asset.atlas].size[1]))
		if rectangle.size.x <= 0 or rectangle.size.y <= 0 or not bounds.encloses(rectangle):
			return false
		assets[asset.id] = asset
	var ids: Dictionary = {}
	for value: Variant in visual.get("props", []):
		if not value is Dictionary or not _id(value.get("id")) or not _numbers(value.get("position"), 3) or not value.get("layers") is Array:
			return false
		var prop: Dictionary = value
		if ids.has(prop.id) or prop.layers.is_empty():
			return false
		ids[prop.id] = true
		for layer: Variant in prop.layers:
			if not layer is Dictionary or not assets.has(layer.get("asset")) or not _numbers(layer.get("size"), 2):
				return false
			if layer.size[0] <= 0 or layer.size[1] <= 0 or not _numbers(layer.get("offset", [0, 0, 0]), 3):
				return false
	for surface: Variant in visual.get("surfaces", []):
		if not surface is Dictionary or not _id(surface.get("id")) or ids.has(surface.id):
			return false
		ids[surface.id] = true
		if not assets.has(surface.get("asset")) or not _numbers(surface.get("position"), 3) or not _numbers(surface.get("size"), 2):
			return false
		if minf(surface.size[0], surface.size[1]) <= 0 or not _numbers(surface.get("rotation", [0, 0, 0]), 3):
			return false
	return true


static func _numbers(values: Variant, count: int) -> bool:
	return values is Array and values.size() == count and values.all(func(value: Variant) -> bool: return (value is float or value is int) and is_finite(float(value)))


static func _id(value: Variant) -> bool:
	return value is String and not value.is_empty()
