extends RigidBody2D

@export var x_velocity = 0
@export var y_velocity = 0
@export var min_speed = 40
@export var slowdown_per_sec = 0.5
@export var slowdown_low_support_per_sec = 0.1

@onready var sprite = $Sprite2D
@onready var particle_hitbox = $ParticleFinder/ParticleSupport

var test = false
var starting_velocity
var color_vec = [1,1,1]
var supporting_particles_angles = {}

var delay = true
var num_supporting = 0

func _ready() -> void:
	linear_velocity = Vector2(x_velocity, y_velocity)
	starting_velocity = linear_velocity.length()
	particle_hitbox.disabled = true
	#sprite.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_move(delta)
	if handle_visual_strength():
		get_parent().remove_particle(self)
		queue_free()
	if not delay:
		calc_angles()
		#queue_redraw()
		handle_slowdown(delta)

func handle_move(delta: float) -> void:
	var collision = move_and_collide(linear_velocity * delta)
	if collision:
		linear_velocity = linear_velocity.bounce(collision.get_normal())
	sprite.rotation = linear_velocity.angle() + deg_to_rad(90)
	particle_hitbox.get_parent().rotation = linear_velocity.angle() + deg_to_rad(90)

func calc_angles():
	for particle in supporting_particles_angles:
		if is_instance_valid(particle):
			supporting_particles_angles[particle] = rad_to_deg(linear_velocity.normalized().angle_to(particle.get_speed().normalized()))

func handle_slowdown(delta):
	num_supporting = 0
	for particle in supporting_particles_angles:
		if is_instance_valid(particle):
			if abs(supporting_particles_angles[particle]) < 10: 
				num_supporting += 1
				if test: 
					particle.color_vec = [0,1,0]
			elif test: particle.color_vec = [1,0,0]

	var factor = 1 - (slowdown_per_sec * delta)
	if num_supporting == 1:
		factor = 1 - (slowdown_low_support_per_sec * delta)
	elif num_supporting > 1:
		factor = 1
	slowdown(factor)

func _draw():
	if num_supporting > 1:
		for particle in supporting_particles_angles:
			if is_instance_valid(particle):
				if abs(supporting_particles_angles[particle]) < 10: 
					draw_line(Vector2.ZERO, particle.position-position, Color(0, 1, 1,
					(linear_velocity.length()-min_speed)/(starting_velocity-min_speed)
					), 5)

func handle_visual_strength() -> bool:
	sprite.modulate = Color(color_vec[0],color_vec[1],color_vec[2], 
			(linear_velocity.length()-min_speed)/(starting_velocity-min_speed))
	return linear_velocity.length() < min_speed

func set_tester():
	color_vec = [1,1,0]
	self.test = true

func get_speed():
	return self.linear_velocity

func get_location():
	return self.position

func slowdown(factor):
	self.linear_velocity = linear_velocity*factor

func start_checking_for_slowdown():
	delay = false
	particle_hitbox.disabled = false

func _on_particle_finder_body_entered(body: Node2D) -> void:
	if not delay:
		if get_parent().is_particle(body) and body != self:
			if body not in supporting_particles_angles:
				supporting_particles_angles[body] = 0
				if test: 
					body.color_vec = [1,0,0]

func _on_particle_finder_body_exited(body: Node2D) -> void:
	if not delay:
		if get_parent().is_particle(body):
			if body in supporting_particles_angles:
				supporting_particles_angles.erase(body)
				if test: 
					body.color_vec = [1,1,1]
