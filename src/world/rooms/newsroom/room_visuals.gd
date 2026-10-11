extends Node3D
## Authored cutout groups mounted without changing spatial target IDs.

const PROP = preload("res://src/world/props/sprite_prop.tscn")


func build(definition: Dictionary, resources: Dictionary) -> void:
	for item: Dictionary in definition.get("props", []):
		var prop := PROP.instantiate()
		prop.configure(item, resources)
		add_child(prop)
