extends Node3D
## A cutout prop owns visual layers; physics and interaction belong to the room.

var layers: Array[Sprite3D] = []


func configure(definition: Dictionary, resources: Dictionary) -> void:
	name = definition.id
	position = Vector3(definition.position[0], definition.position[1], definition.position[2])
	for item: Dictionary in definition.layers:
		var asset: Dictionary = resources.assets[item.asset]
		var region := AtlasTexture.new()
		region.atlas = resources.textures[asset.atlas]
		region.region = Rect2(asset.region[0], asset.region[1], asset.region[2], asset.region[3])
		var sprite := Sprite3D.new()
		sprite.texture = region
		sprite.pixel_size = item.size[0] / asset.region[2]
		sprite.scale.y = item.size[1] / (asset.region[3] * sprite.pixel_size)
		sprite.offset.y = asset.region[3] / 2.0
		sprite.position = Vector3(item.get("offset", [0, 0, 0])[0], item.get("offset", [0, 0, 0])[1], item.get("offset", [0, 0, 0])[2])
		sprite.shaded = item.get("shaded", true)
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sprite.modulate = Color(item.get("tint", "#ffffff"))
		add_child(sprite)
		layers.append(sprite)
