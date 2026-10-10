extends SceneTree


func _initialize() -> void:
	var arguments := OS.get_cmdline_user_args()
	assert(arguments.size() == 1, "Expected output PNG path")
	assert(not FileAccess.file_exists(arguments[0]), "Preserve historical mask evidence")
	var image := Image.new()
	var result := image.load_svg_from_buffer(FileAccess.get_file_as_bytes("res://assets/ui/coastal/source/review/ui-mask.svg"))
	assert(result == OK, "Cannot rasterize conservative review mask")
	assert(image.save_png(arguments[0]) == OK, "Cannot save review mask")
	print("Review mask saved")
	quit()
