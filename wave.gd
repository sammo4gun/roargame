extends Node2D

var particle = load("res://particle.tscn")

@export var wave_speed = 50
@export var num_particles = 4
@export var slowdown_per_sec = 0.80
@export var slowdown_low_support_per_sec = 0.2
@export var dist_until_slowdown = 40
@export var min_particle_speed = 40

@export var focus_angle = 0.2 # this much % of the circle...
@export var focus_intensity = 0.5 # ...has this much % of the particles.

@export var focus_angle_curve: Curve

@export var focus_strength = 0.3 # how much extra % of speed the focused part will have MAXIMALLY

@export var focus_strength_curve: Curve

var focus_degree = 0
var slowed = false
var particles = []
var test = true
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_degree = randf_range(0, 360)
	print(focus_degree)
	if focus_angle < 1 and focus_angle > 0:
		focused_wave(focus_degree)
	else:
		full_wave(focus_degree)

func focused_wave(degree):
	# the amount to 'jump forward' for every particle in the focused zone
	var num_focused = int(num_particles * focus_intensity)
	var num_unfocused = num_particles - num_focused
	var particle_focus_angle = (360.0 * focus_angle) / num_focused
	# the amount to 'jump forward' for every particle in the unfocused zone
	var particle_regular_angle = (360.0 * (1-focus_angle)) / num_unfocused
	# to make sure the middle of the focused zone is the direction of the degree
	var current_angle = degree - (360.0 * 0.5 * focus_angle) 
	var num_spawned = 0
	while num_spawned < num_particles:
		if num_spawned < num_focused:
			make_particle(	current_angle,
							wave_speed+
							wave_speed*focus_strength*(focus_strength_curve.sample(num_spawned/float(num_focused))),
							int(current_angle) == int(focus_degree))
			#current_angle += particle_focus_angle * focus_angle_curve.sample(num_spawned/float(num_focused))
			current_angle += particle_focus_angle
		else:
			make_particle(current_angle)
			current_angle += particle_regular_angle
		num_spawned += 1

func full_wave(degree):
	var particle_angle = 360.0/num_particles
	var current_angle = degree
	var num_spawned = 0
	while num_spawned < num_particles:
		make_particle(current_angle)
		current_angle += particle_angle
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
	

func _process(delta):
	if not slowed: 
		t = t + delta
		if t * wave_speed > 20:
			for part in particles:
				if part.delay:
					part.start_checking_for_slowdown()
	if particles == []:
		queue_free()

func remove_particle(part):
	particles.erase(part)

func get_all_particles():
	return particles

func is_particle(entity):
	return entity in particles
