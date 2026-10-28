extends RefCounted
## Procedural stress textures; plates are generated at runtime so no 4K bytes are committed.

static var _plates := {}


## Returns a plate texture at the source size. A positive prefilter_lod bakes the far-plate
## blur into the pixels (shrink then enlarge) so no runtime blur pass is needed.
## Images are cached per process so repeated variants skip regeneration.
## frequency_scale converts the spec noise frequency (authored per display pixel) to source pixels.
static func plate(definition: Dictionary, size: Array, downsample: int, frequency_scale: float, import_mode: String, prefilter_lod: float) -> Texture2D:
	var key := "%s:%s:%dx%d:%s" % [definition.id, import_mode, int(size[0]), int(size[1]), prefilter_lod]
	if not _plates.has(key):
		var image := _noise_rgba(definition, int(size[0]), int(size[1]), downsample, frequency_scale)
		if prefilter_lod > 0.0:
			var factor := int(pow(2.0, prefilter_lod))
			image.resize(image.get_width() / factor, image.get_height() / factor, Image.INTERPOLATE_BILINEAR)
			image.resize(int(size[0]), int(size[1]), Image.INTERPOLATE_CUBIC)
		if import_mode == "vram_bptc":
			var status := image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_SRGB)
			assert(status == OK, "BPTC compression failed: %d" % status)
		_plates[key] = image
	return ImageTexture.create_from_image(_plates[key])


## Reinterprets a 4x-wide L8 noise field as RGBA8, giving smooth colour and alpha noise
## without a per-pixel GDScript loop.
static func _noise_rgba(definition: Dictionary, width: int, height: int, downsample: int, frequency_scale: float) -> Image:
	var noise := FastNoiseLite.new()
	noise.seed = int(definition.seed)
	noise.frequency = float(definition.frequency) * downsample * frequency_scale
	noise.fractal_octaves = 4
	var small_w := width / downsample
	var small_h := height / downsample
	var field := noise.get_image(small_w * 4, small_h)
	var image := Image.create_from_data(small_w, small_h, false, Image.FORMAT_RGBA8, field.get_data())
	if bool(definition.opaque):
		image.convert(Image.FORMAT_RGB8)
		image.convert(Image.FORMAT_RGBA8)
	image.resize(width, height, Image.INTERPOLATE_BILINEAR)
	return image


static func radial(size_px: int, inner: Color) -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, inner)
	gradient.set_color(1, Color(inner, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = size_px
	texture.height = size_px
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	return texture


static func shaft() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color.WHITE)
	gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 64
	texture.height = 256
	texture.fill_from = Vector2(0.5, 0.0)
	texture.fill_to = Vector2(0.5, 1.0)
	return texture


## Capsule-like actor silhouette with an optional flat (0, 0, 1) normal map.
static func actor(size: Array, normal_map: bool) -> Texture2D:
	var width := int(size[0])
	var height := int(size[1])
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(width / 4, height / 5, width / 2, height * 4 / 5), Color.WHITE)
	image.fill_rect(Rect2i(width * 3 / 8, 0, width / 4, height / 5), Color.WHITE)
	var diffuse := ImageTexture.create_from_image(image)
	if not normal_map:
		return diffuse
	var flat := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	flat.fill(Color(0.5, 0.5, 1.0, 1.0))
	var canvas := CanvasTexture.new()
	canvas.diffuse_texture = diffuse
	canvas.normal_texture = ImageTexture.create_from_image(flat)
	return canvas


static func white(size_px: int) -> ImageTexture:
	var image := Image.create_empty(size_px, size_px, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
