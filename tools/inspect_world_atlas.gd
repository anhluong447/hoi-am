extends SceneTree
## Read alpha bounds only; source pixels are neither changed nor exported.


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 4, "Expected source, columns, rows and JSON output")
	var bitmap := Image.load_from_file(args[0])
	assert(bitmap != null)
	var columns := int(args[1])
	var rows := int(args[2])
	var cell := Vector2i(bitmap.get_width() / columns, bitmap.get_height() / rows)
	var regions: Array = []
	for index: int in columns * rows:
		var origin := Vector2i(index % columns * cell.x, index / columns * cell.y)
		var used := bitmap.get_region(Rect2i(origin, cell)).get_used_rect()
		regions.append([origin.x + used.position.x, origin.y + used.position.y, used.size.x, used.size.y])
	var output := FileAccess.open(args[3], FileAccess.WRITE)
	output.store_string(JSON.stringify({"size": [bitmap.get_width(), bitmap.get_height()], "regions": regions}, "  "))
	output.close()
	print("Atlas alpha bounds: %d regions; source preserved" % regions.size())
	quit()
