extends Node2D

var particle = load("res://particle.tscn")

@export var wave_speed = 50
@export var total_particles = 4

@export var slowdown_per_sec = 0.80
@export var slowdown_low_support_per_sec = 0.2
@export var dist_until_slowdown = 40
@export var min_particle_speed = 40

@export var focus_angle_curve: Curve
@export var focus_strength_curve: Curve

var focus_strength_factor = 0

var started = false
var focus_degree = 0
var slowed = false
var particles = []
var t = 0
var hold_t = 0

func _process(delta):
	if not started:
		focus_degree = rad_to_deg((Vector2.ZERO - get_local_mouse_position()).angle()) + 180
		focus_strength_factor = (Vector2.ZERO - get_local_mouse_position()).length() / 200
		focus_angle_curve.set_point_value(1, 2/(1+(3*focus_strength_factor)))
		if Input.is_action_just_released('mouseClick'):
			wave(wave_speed, focus_angle_curve, focus_strength_curve, focus_strength_factor, total_particles, focus_degree)
		queue_redraw()
	else:
		if not slowed: 
			t = t + delta
			if t * wave_speed > 20:
				for part in particles:
					if part.delay:
						part.start_checking_for_slowdown()
		if particles == []:
			queue_free()

func _draw():
	if not started: 
		draw_line(Vector2.ZERO, get_local_mouse_position(), Color(0, 1, 1), 5)

func wave(speed, focus_curve, strength_curve, strength_factor, num_particles, degree):
	get_parent().wave_spawned()
	if strength_factor > 2:
		speed = speed / (strength_factor/2)
	started = true
	# to make sure the middle of the focused zone is the direction of the degree
	var current_angle = degree - (360.0 * 0.5) 
	var num_spawned = 0
	
	var focus_norm = 0
	var i = 0
	while i < num_particles:
		focus_norm += focus_curve.sample(i/float(num_particles))
		i+=1
	
	while num_spawned < num_particles:
		make_particle(current_angle,
					  speed +
					  strength_factor * speed * 
					  strength_curve.sample(num_spawned/float(num_particles)),
					  int(current_angle) == int(degree))
		current_angle += 360 * focus_curve.sample(num_spawned/float(num_particles)) / focus_norm
		num_spawned += 1

func make_particle(fire_angle, speed=wave_speed, tester = false):
	var instance = particle.instantiate()
	if tester:
		instance.set_tester()
	instance.x_velocity = cos(deg_to_rad(fire_angle)) * speed
	instance.y_velocity = sin(deg_to_rad(fire_angle)) * speed
	instance.slowdown_per_sec = slowdown_per_sec
	instance.min_speed = min_particle_speed
	instance.slowdown_low_support_per_sec = slowdown_low_support_per_sec
	add_child(instance)
	particles.append(instance)

func remove_particle(part):
	particles.erase(part)

func get_all_particles():
	return particles

func is_particle(entity):
	return entity in particles
