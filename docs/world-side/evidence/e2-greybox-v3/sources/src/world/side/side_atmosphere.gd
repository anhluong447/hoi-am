extends Node2D
## Floating dust motes for a side room. CPU particles (no compute on
## integrated GPUs), fixed seed from composition, count = density x MAX_DUST.
## Emits only when enabled by quality and motion is not reduced.

const MAX_DUST := 120
const LIFETIME := 9.0

var particles: CPUParticles2D
var _density := 0.0
var _enabled := true
var _reduced := false


## spec: {"min_x", "max_x", "height"} in room units.
func configure(spec: Dictionary, seed_value: int) -> void:
	var min_x := float(spec.min_x)
	var max_x := float(spec.max_x)
	var height := float(spec.height)
	particles = CPUParticles2D.new()
	particles.name = "Dust"
	particles.use_fixed_seed = true
	particles.seed = seed_value
	particles.lifetime = LIFETIME
	particles.preprocess = LIFETIME
	particles.position = Vector2((min_x + max_x) * 0.5, height * 0.45)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2((max_x - min_x) * 0.5, height * 0.4)
	particles.direction = Vector2(1.0, -0.2)
	particles.spread = 180.0
	particles.gravity = Vector2(0.0, 3.0)
	particles.initial_velocity_min = 4.0
	particles.initial_velocity_max = 12.0
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 3.5
	particles.color = Color(1.0, 0.95, 0.85, 0.35)
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 1.0, 1.0, 0.0))
	fade.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	fade.add_point(0.5, Color.WHITE)
	particles.color_ramp = fade
	add_child(particles)
	_refresh()


func set_density(value: float) -> void:
	_density = clampf(value, 0.0, 1.0)
	_refresh()


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	_refresh()


func set_reduced_motion(reduced: bool) -> void:
	_reduced = reduced
	_refresh()


func _refresh() -> void:
	if particles == null:
		return
	var count := roundi(_density * MAX_DUST)
	if count > 0 and particles.amount != count:
		particles.amount = count
	var active := _enabled and not _reduced and count > 0
	particles.emitting = active
	particles.visible = active
