extends Node3D
## A cutout prop owns visual layers; physics and interaction belong to the room.

var layers: Array[Sprite3D] = []
const ART = preload("res://src/world/props/cutout_art.gdshader")


func configure(definition: Dictionary, resources: Dictionary) -> void:
	name = definition.id
	position = Vector3(definition.position[0], definition.position[1], definition.position[2])
	if definition.has("idle"):
		set_meta("idle", definition.idle.duplicate(true))
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
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS if item.get("mipmaps", true) else BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if item.get("shadow", false) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		sprite.modulate = Color(item.get("tint", "#ffffff"))
		if resources.get("texel_step", 1.0) > 1.0:
			var material := ShaderMaterial.new()
			material.shader = ART
			material.set_shader_parameter("atlas", region.atlas)
			material.set_shader_parameter("atlas_size", Vector2(region.atlas.get_width(), region.atlas.get_height()))
			material.set_shader_parameter("texel_step", resources.texel_step)
			material.set_shader_parameter("tint", sprite.modulate)
			sprite.material_override = material
		add_child(sprite)
		layers.append(sprite)
