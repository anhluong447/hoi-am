extends RefCounted
## Builds the existing coastal composition into separately animated groups.

const WIDGETS = preload("res://src/presentation/coastal/coastal_widgets.gd")
const CHOICES = preload("res://src/presentation/coastal/dialogue_choices.gd")
const TEXT = preload("res://src/presentation/coastal/dialogue_text.gd")


static func build(parent: Control, model: Dictionary, layout: Dictionary, resources: Dictionary) -> Dictionary:
	var layers: Dictionary = {}
	var labels: Dictionary = {}
	for id: String in ["wave", "paper", "date", "speaker", "body"]:
		layers[id] = _group(parent)
	WIDGETS.art(layers.wave, resources.wave, [0, 0, layout.stage[0], layout.stage[1]])
	for id: String in ["paper", "dialogue-wash", "print"]:
		WIDGETS.art(layers.paper, resources[id], [0, 0, layout.stage[0], layout.stage[1]])
	WIDGETS.art(layers.date, resources.date, [0, 0, layout.stage[0], layout.stage[1]])
	layers.proceed = _group(parent)
	for spec: Dictionary in layout.text:
		if spec.get("optionalLogo", false):
			continue
		var family: String = spec.get("family", "Source Serif 4")
		var group: Control = layers.date
		if spec.id in ["speaker", "line", "continue"]:
			group = layers[{"speaker": "speaker", "line": "body", "continue": "proceed"}[spec.id]]
		labels[spec.id] = WIDGETS.copy(group, model.get(spec.id, ""), spec, resources[family], resources.coastal_weights[family])
	var reading := TEXT.new()
	layers.body.add_child(reading)
	reading.configure(labels.line, layout.motion.typewriter)
	var choices := CHOICES.new()
	parent.add_child(choices)
	layers.choices = choices
	choices.configure(model, layout, resources, false, true)
	WIDGETS.art(layers.proceed, resources["icon-return"], layout.returnIcon)
	var proceed := WIDGETS.target(layers.proceed, layout.continueBounds, model.get("continue", ""))
	# Keep the foreground above choices and all live dialogue text.
	for id: String in ["flowers", "notebook"]:
		layers[id] = _group(parent)
		layers[id].pivot_offset = Vector2(layout.motion.pivots[id][0], layout.motion.pivots[id][1])
		WIDGETS.art(layers[id], resources[id], [0, 0, layout.stage[0], layout.stage[1]])
	WIDGETS.art(layers.notebook, resources["note-wash"], [0, 0, layout.stage[0], layout.stage[1]])
	for spec: Dictionary in layout.environmentText:
		var adjusted := spec.duplicate(true)
		adjusted.x = 0
		adjusted.y = 0
		var pose: Dictionary = layout.note_copy
		var rig := Node2D.new()
		rig.transform = Transform2D(Vector2(pose.basis[0], pose.basis[1]), Vector2(pose.basis[2], pose.basis[3]), Vector2(pose.origin[0], pose.origin[1])) * Transform2D(deg_to_rad(pose.rotation), Vector2(pose.anchor[0], pose.anchor[1]))
		layers.notebook.add_child(rig)
		var surface := _group(rig)
		labels[spec.id] = WIDGETS.copy(surface, model.get(spec.id, ""), adjusted, resources[spec.family], resources.coastal_weights[spec.family])
	return {"layers": layers, "labels": labels, "reading": reading, "choices": choices, "proceed": proceed}


static func _group(parent: Node) -> Control:
	var group := Control.new()
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(group)
	return group
