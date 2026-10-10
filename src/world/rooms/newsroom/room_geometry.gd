extends Node3D
## Concrete greybox geometry from authored room boxes, including physical window gaps.


func build(definitions: Array) -> void:
	for item: Dictionary in definitions:
		var body := StaticBody3D.new()
		body.name = item.id
		body.position = vector(item.position)
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = vector(item.size)
		mesh.mesh = box
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(item.color)
		material.roughness = 0.86
		mesh.material_override = material
		body.add_child(mesh)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = box.size
		collision.shape = shape
		body.add_child(collision)
		add_child(body)


static func vector(values: Array) -> Vector3:
	return Vector3(values[0], values[1], values[2])
