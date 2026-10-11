extends Node3D
## Concrete greybox geometry from authored room boxes, including physical window gaps.
const SURFACE = preload("res://src/world/rooms/newsroom/coastal_surface.gdshader")


func build(definitions: Array) -> void:
	for item: Dictionary in definitions:
		var body := StaticBody3D.new()
		body.name = item.id
		body.position = vector(item.position)
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = vector(item.size)
		mesh.mesh = box
		if not item.get("visible", true):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if item.get("shadow", true) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mesh.visible = item.get("shadow", true)
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(item.color)
		material.roughness = 0.86
		if item.has("surface"):
			var authored := ShaderMaterial.new()
			authored.shader = SURFACE
			authored.set_shader_parameter("tint", Color(item.color))
			for key: String in item.surface:
				authored.set_shader_parameter(key, item.surface[key])
			mesh.material_override = authored
		else:
			mesh.material_override = material
		body.add_child(mesh)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = box.size
		collision.shape = shape
		if item.get("collision", true):
			body.add_child(collision)
		else:
			collision.free()
		add_child(body)


static func vector(values: Array) -> Vector3:
	return Vector3(values[0], values[1], values[2])
