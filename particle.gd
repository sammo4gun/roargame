extends RigidBody2D

@export var x_velocity = 0;
@export var y_velocity = 0;
@export var speed_min = 5;

@onready var sprite = $Sprite2D
@onready var particle_finder = $ParticleFinder

var test = false
var starting_velocity
var color_vec = [1,1,1]
var supporting_particles = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linear_velocity = Vector2(x_velocity, y_velocity)
	starting_velocity = linear_velocity.length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	handle_move(delta)
	if handle_visual_strength():
		get_parent().remove_particle(self)
		queue_free()
	
	get_support()
	
	#slowdown(0.99)

func handle_move(delta: float) -> void:
	var collision = move_and_collide(linear_velocity * delta)
	if collision:
		linear_velocity = linear_velocity.bounce(collision.get_normal())

func get_support():
	var factor = 0.95
	for particle in supporting_particles:
		if is_instance_valid(particle):
			var angle = rad_to_deg(linear_velocity.normalized().angle_to(particle.get_speed().normalized()))
			if test: print(angle)
			if angle < 15 and angle > -15: factor += 0.01
	slowdown(factor)

func handle_visual_strength() -> bool:
	sprite.modulate = Color(color_vec[0],color_vec[1],color_vec[2], 
			(linear_velocity.length()-speed_min)/(starting_velocity-speed_min))
	return linear_velocity.length() < speed_min

func set_tester():
	color_vec = [1,0,1]
	self.test = true

func get_speed():
	return self.linear_velocity

func get_location():
	return self.position

func slowdown(factor):
	self.linear_velocity = linear_velocity*factor

func _on_particle_finder_body_entered(body: Node2D) -> void:
	if get_parent().is_particle(body) and body != self:
		if body not in supporting_particles:
			supporting_particles.append(body)
			if test: 
				body.color_vec = [1,0,0]

func _on_particle_finder_body_exited(body: Node2D) -> void:
	if get_parent().is_particle(body):
		if body in supporting_particles:
			supporting_particles.erase(body)
			if test: 
				body.color_vec = [1,1,1]
