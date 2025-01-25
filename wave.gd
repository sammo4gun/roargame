extends Node2D

var particle = load("res://particle.tscn")

@export var wave_speed = 50
@export var num_particles = 4
@export var loc_sim_norm = 100
@export var speed_sim_norm = 100

var particles = []
var test = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var angle = 360.0/num_particles
	var current_angle = 0
	while current_angle < 360:
		var instance = particle.instantiate()
		if test:
			instance.set_tester()
			test = false
		instance.x_velocity = cos(deg_to_rad(current_angle)) * wave_speed
		instance.y_velocity = sin(deg_to_rad(current_angle)) * wave_speed
		add_child(instance)
		particles.append(instance)
		current_angle += angle

func remove_particle(part):
	particles.erase(part)

func get_all_particles():
	return particles

func is_particle(entity):
	return entity in particles
