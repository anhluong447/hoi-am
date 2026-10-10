extends CharacterBody3D

var input_enabled := true
var speed := 0.0
var gravity := 0.0
var camera: Camera3D


func configure(config: Dictionary, definition: Dictionary, texture: Texture2D, view_camera: Camera3D) -> void:
	speed = config.speed
	gravity = config.gravity
	camera = view_camera
	var shape := CapsuleShape3D.new()
	shape.radius = config.collider.radius
	shape.height = config.collider.height
	$Collision.shape = shape
	$Collision.position.y = shape.height / 2.0
	$Rig.configure(definition, texture, config.actor_pixel_size, config.stride_world)


func _physics_process(delta: float) -> void:
	var before := position
	var axes := Input.get_vector("move_left", "move_right", "move_up", "move_down") if input_enabled else Vector2.ZERO
	var right := camera.global_basis.x
	var forward := camera.global_basis.z
	right.y = 0
	forward.y = 0
	var direction := (right.normalized() * axes.x + forward.normalized() * axes.y).limit_length()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = -gravity * delta if is_on_floor() else velocity.y - gravity * delta
	move_and_slide()
	$Rig.present(position - before, camera)


func set_input_enabled(enabled: bool) -> void:
	input_enabled = enabled
	if not enabled:
		velocity.x = 0
		velocity.z = 0
