extends Node3D
## Authored cutout groups mounted without changing spatial target IDs.

const PROP = preload("res://src/world/props/sprite_prop.tscn")
const SURFACE = preload("res://src/world/rooms/newsroom/painted_surface.gdshader")


func build(definition: Dictionary, resources: Dictionary) -> void:
	for item: Dictionary in definition.get("surfaces", []):
		_surface(item, resources)
	for item: Dictionary in definition.get("props", []):
		var prop := PROP.instantiate()
		prop.configure(item, resources)
		add_child(prop)
	for item: Dictionary in definition.get("labels", []):
		var label := Label3D.new()
		label.name = item.id
		label.text = item.text
		label.font = resources.font
		label.font_size = item.font_size
		label.pixel_size = item.pixel_size
		label.modulate = Color(item.color)
		label.outline_size = 0
		label.position = Vector3(item.position[0], item.position[1], item.position[2])
		add_child(label)


func _surface(item: Dictionary, resources: Dictionary) -> void:
	var node := MeshInstance3D.new()
	node.name = item.id
	var quad := QuadMesh.new()
	quad.size = Vector2(item.size[0], item.size[1])
	node.mesh = quad
	node.position = Vector3(item.position[0], item.position[1], item.position[2])
	var rotation: Array = item.get("rotation", [0, 0, 0])
	node.rotation_degrees = Vector3(rotation[0], rotation[1], rotation[2])
	var asset: Dictionary = resources.assets[item.asset]
	var texture: Texture2D = resources.textures[asset.atlas]
	var material := ShaderMaterial.new()
	material.shader = SURFACE
	material.set_shader_parameter("atlas", texture)
	material.set_shader_parameter("atlas_region", Vector4(asset.region[0] / float(texture.get_width()), asset.region[1] / float(texture.get_height()), asset.region[2] / float(texture.get_width()), asset.region[3] / float(texture.get_height())))
	var repeat_count: Array = item.get("repeat", [1, 1])
	material.set_shader_parameter("repeat_count", Vector2(repeat_count[0], repeat_count[1]))
	material.set_shader_parameter("tint", Color(item.get("tint", "#ffffff")))
	material.set_shader_parameter("ink_strength", item.get("ink_strength", 1.0))
	material.set_shader_parameter("swap_axes", item.get("swap_axes", false))
	node.material_override = material
	add_child(node)
