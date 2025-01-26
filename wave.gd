extends Node2D

var particle = load("res://particle.tscn")

@export var wave_speed = 50
@export var num_particles = 4
@export var slowdown_per_sec = 0.80
@export var slowdown_low_support_per_sec = 0.2
@export var dist_until_slowdown = 40
@export var min_particle_speed = 40

@export var focus_angle = 0.2
@export var focus_intensity = 0.5

var focus_dir = 0
var slowed = false
var particles = []
var test = true
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_dir = randf_range(0, 360)
	var angle = 360.0/num_particles
	var current_angle = 0
	while current_angle < 360:
		var instance = particle.instantiate()
		if test:
			instance.set_tester()
			test = false
		instance.x_velocity = cos(deg_to_rad(current_angle+focus_dir)) * wave_speed
		instance.y_velocity = sin(deg_to_rad(current_angle+focus_dir)) * wave_speed
		instance.slowdown_per_sec = slowdown_per_sec
		instance.min_speed = min_particle_speed
		instance.slowdown_low_support_per_sec = slowdown_low_support_per_sec
		add_child(instance)
		particles.append(instance)
		current_angle += angle

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
