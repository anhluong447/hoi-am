extends Area3D

var target_id := ""
var anchor := Vector3.ZERO


func configure(definition: Dictionary) -> void:
	target_id = definition.id
	position = Vector3(definition.position[0], definition.position[1], definition.position[2])
	anchor = Vector3(definition.anchor[0], definition.anchor[1], definition.anchor[2])
	collision_layer = 0
	collision_mask = 2
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = definition.radius
	collision.shape = sphere
	add_child(collision)


func player_nearby(player: CharacterBody3D) -> bool:
	return overlaps_body(player)
