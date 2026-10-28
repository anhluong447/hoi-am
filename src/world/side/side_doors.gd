extends RefCounted
## Door lookup/prompt helpers for side rooms. Doors and interactions share one
## id namespace and content authors must keep their ranges from overlapping
## (enforced by side_room_rules.gd), so a single nearby id is never ambiguous:
## TARGETS.find against doors resolves whether it names a door or a target.

const TARGETS = preload("res://src/world/side/side_targets.gd")
const PROMPT_HEIGHT_RATIO := 0.6


static func nearby(interactions: Array, doors: Array, x: float) -> String:
	var hit := TARGETS.nearest(interactions, x)
	return hit if not hit.is_empty() else TARGETS.nearest(doors, x)


static func label_key(doors: Array, id: String) -> String:
	return str(TARGETS.find(doors, id).get("label_key", ""))


## Marker nodes for both interaction and door prompts (anchor_for/target_label_key
## share this one id -> marker map). Door prompts anchor above the doorway at a
## fixed fraction of actor height, since doors carry no authored anchor_y.
static func build_targets(parent: Node2D, interactions: Array, doors: Array, floor_y: float, actor_height: float) -> Dictionary:
	var markers: Dictionary = {}
	for interaction: Dictionary in interactions:
		var marker := Node2D.new()
		marker.name = str(interaction.id)
		marker.position = Vector2(float(interaction.x), float(interaction.anchor_y))
		parent.add_child(marker)
		markers[interaction.id] = marker
	var anchor_y := floor_y - actor_height * PROMPT_HEIGHT_RATIO
	for door: Dictionary in doors:
		var marker := Node2D.new()
		marker.name = str(door.id)
		marker.position = Vector2(float(door.x), anchor_y)
		parent.add_child(marker)
		markers[door.id] = marker
	return markers
