extends "res://tests/test_suite.gd"

const MOTION = preload("res://src/world/side/side_motion.gd")
const ACTOR = preload("res://src/world/side/side_actor.tscn")
const CAMERA = preload("res://src/world/side/side_camera.gd")

const TUNING := {
	"max_speed": 360.0,
	"accel_time": 0.10,
	"decel_time": 0.08,
	"stride": 180.0,
	"bob": 4.0,
	"camera_dead_zone": 120.0,
	"camera_response": 0.08,
	"actor_height": 300.0,
	"actor_half_width": 40.0,
}


func run() -> void:
	var velocity := 0.0
	for _step: int in 6:
		velocity = MOTION.step(velocity, 1.0, 1.0 / 60.0, TUNING)
	expect(is_equal_approx(velocity, 360.0) or absf(velocity - 360.0) < 1.0, "Accelerates to max speed within accel_time")

	velocity = 360.0
	var decel_steps := int(round(0.08 * 60.0))
	for _step: int in decel_steps:
		var previous := velocity
		velocity = MOTION.step(velocity, 0.0, 1.0 / 60.0, TUNING)
		expect(velocity >= 0.0, "Deceleration never overshoots sign")
		expect(velocity <= previous, "Deceleration is monotonic")
	expect(is_equal_approx(velocity, 0.0), "Fully decelerates within decel_time")

	velocity = 360.0
	var first := MOTION.step(velocity, -1.0, 1.0 / 60.0, TUNING)
	expect(first > -360.0 and first < 360.0, "Direction reversal ramps through zero, no instant flip")
	var crossed_zero := false
	for _step: int in 400:
		velocity = MOTION.step(velocity, -1.0, 1.0 / 60.0, TUNING)
		if velocity < 0.0:
			crossed_zero = true
			break
	expect(crossed_zero, "Reversal eventually crosses zero into the new direction")

	expect(MOTION.clamp_x(9999.0, {"min_x": 0.0, "max_x": 2000.0}, 40.0) == 1960.0, "clamp_x respects half width at far edge")
	expect(is_equal_approx(MOTION.step(0.0, NAN, 1.0 / 60.0, TUNING), 0.0), "NaN axis treated as zero")

	var actor := ACTOR.instantiate()
	Engine.get_main_loop().root.add_child(actor)
	actor.configure(null, TUNING.actor_height, TUNING)
	var bounds := {"min_x": 0.0, "max_x": 100.0}
	actor.position.x = 95.0
	for _step: int in 60:
		actor.move(1.0, 1.0 / 60.0, bounds)
	expect(is_equal_approx(actor.velocity, 0.0), "Actor stops at the bound")
	var travelled_at_wall: float = actor.travelled
	for _step: int in 10:
		actor.move(1.0, 1.0 / 60.0, bounds)
	expect(is_equal_approx(actor.travelled, travelled_at_wall), "Travelled does not grow while pressed against the wall")
	actor.queue_free()

	var camera := CAMERA.new()
	Engine.get_main_loop().root.add_child(camera)
	var cam_bounds := {"min_x": 0.0, "max_x": 2000.0}
	camera.configure(cam_bounds, 1080.0, TUNING)
	camera.position.x = 0.0
	for _step: int in 120:
		camera.follow(2000.0, 1.0 / 60.0, false)
		expect(camera.position.x >= cam_bounds.min_x and camera.position.x <= cam_bounds.max_x, "Camera never exceeds limits while following")
	expect(camera.position.x > 500.0, "Camera has advanced toward the target after 120 steps")
	camera.follow(1500.0, 1.0 / 60.0, true)
	expect(is_equal_approx(camera.position.x, 1500.0), "Reduced motion snaps to the clamped target immediately")
	camera.queue_free()
