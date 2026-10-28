extends RefCounted
## Pure 1D target lookup for side rooms: a target covers |x - t.x| <= t.width/2.


static func nearest(targets: Array, x: float) -> String:
	var best := ""
	var best_distance := INF
	for target: Dictionary in targets:
		var distance := absf(x - float(target.x))
		if distance <= float(target.width) / 2.0 and distance < best_distance:
			best = str(target.id)
			best_distance = distance
	return best


static func find(targets: Array, id: String) -> Dictionary:
	for target: Dictionary in targets:
		if target.id == id:
			return target
	return {}
