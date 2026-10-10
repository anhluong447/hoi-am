extends RefCounted

var failures: Array[String] = []
var checks := 0


func expect(condition: bool, diagnostic: String) -> void:
	checks += 1
	if not condition:
		failures.append(diagnostic)
