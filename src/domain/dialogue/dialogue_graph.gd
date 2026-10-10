extends RefCounted
## Concrete interpreter for imported next/choices plus authored command intents.


static func validate(graph: Dictionary, catalog: Dictionary) -> bool:
	if not graph.get("nodes") is Dictionary or not graph.nodes.has("start"):
		return false
	var visiting: Array = []
	var visited: Array = []
	return _visit("start", graph.nodes, catalog, visiting, visited) and visited.size() == graph.nodes.size()


static func _visit(id: String, nodes: Dictionary, catalog: Dictionary, visiting: Array, visited: Array) -> bool:
	if id in visiting or not nodes.has(id):
		return false
	if id in visited:
		return true
	var node: Variant = nodes[id]
	if not node is Dictionary or not catalog.has(node.get("text_key")) or not node.get("speaker") is String:
		return false
	visiting.append(id)
	var edges: Array = []
	if node.has("next"):
		edges.append(node.next)
	if node.has("choices"):
		if not node.choices is Array or node.choices.size() > 3:
			return false
		var ids: Array = []
		for index: int in node.choices.size():
			var choice: Variant = node.choices[index]
			if not choice is Dictionary or not catalog.has(choice.get("label_key")) or not choice.get("next") is String:
				return false
			if choice.has("command") and not choice.command is Dictionary:
				return false
			var choice_id: Variant = choice.get("id", str(index))
			if not choice_id is String or choice_id in ids or choice_id.is_empty():
				return false
			ids.append(choice_id)
			edges.append(choice.next)
	for edge: Variant in edges:
		if not edge is String or not _visit(edge, nodes, catalog, visiting, visited):
			return false
	visiting.erase(id)
	visited.append(id)
	return true


static func choices(node: Dictionary, state: Dictionary) -> Array:
	var result: Array = []
	for index: int in node.get("choices", []).size():
		var choice: Dictionary = node.choices[index]
		if choice.has("phase") and state.phase != choice.phase:
			continue
		var copy := choice.duplicate(true)
		copy.id = choice.get("id", str(index))
		result.append(copy)
	return result
