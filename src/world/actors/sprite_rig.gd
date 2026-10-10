extends Node3D
## Atlas registration and presentation clips. Walk frames follow actual distance.

var _definition: Dictionary
var _direction := "down"
var _distance := 0.0
var _stride := 1.0
var _mode := "idle"


func configure(definition: Dictionary, texture: Texture2D, pixel_size: float, stride: float) -> void:
	_definition = definition.duplicate(true)
	_stride = stride
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var width: int = definition.frameWidth
	var height: int = definition.frameHeight
	for clip_name: String in definition.clips:
		var clip: Dictionary = definition.clips[clip_name]
		for index: int in definition.directions.size():
			var animation := clip_name + "_" + str(definition.directions[index])
			frames.add_animation(animation)
			frames.set_animation_speed(animation, 1.0)
			for frame_index: int in clip.columns.size():
				var frame := AtlasTexture.new()
				frame.atlas = texture
				frame.region = Rect2(clip.columns[frame_index] * width, clip.rows[index] * height, width, height)
				var duration: float = float(clip.get("durations", [100])[frame_index]) / 1000.0 if clip.has("durations") else 1.0
				frames.add_frame(animation, frame, duration)
	$Sprite.sprite_frames = frames
	$Sprite.pixel_size = pixel_size
	$Sprite.offset = Vector2(width / 2.0 - definition.pivot.x, definition.pivot.y - height / 2.0)
	$Sprite.position.y = (height - definition.pivot.y) * pixel_size
	$Sprite.play("idle_down")


func present(displacement: Vector3, camera: Camera3D, talking: bool = false) -> void:
	var moving := Vector2(displacement.x, displacement.z).length() > 0.0001
	if moving:
		var right := camera.global_basis.x
		var forward := -camera.global_basis.z
		right.y = 0
		forward.y = 0
		var horizontal := displacement.dot(right.normalized())
		var vertical := displacement.dot(forward.normalized())
		_direction = ("right" if horizontal > 0 else "left") if absf(horizontal) > absf(vertical) else ("up" if vertical > 0 else "down")
		_distance += Vector2(displacement.x, displacement.z).length()
	var mode := "walk" if moving else ("talk" if talking else "idle")
	var animation := mode + "_" + _direction
	if mode == "walk":
		$Sprite.stop()
		$Sprite.animation = animation
		$Sprite.frame = int(floor(fmod(_distance, _stride) / _stride * _definition.clips.walk.columns.size()))
	elif _mode != mode or $Sprite.animation != animation:
		$Sprite.play(animation)
	_mode = mode


func set_direction(direction: String) -> void:
	_direction = direction
	$Sprite.play("idle_" + direction)


func set_shadow_mode(mode: String) -> void:
	$ShadowProxy.visible = mode == "proxy"
	$Contact.visible = mode == "contact"
	$Sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if mode == "sprite" else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func set_billboard(enabled: bool) -> void:
	$Sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y if enabled else BaseMaterial3D.BILLBOARD_DISABLED
