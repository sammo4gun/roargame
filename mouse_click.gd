extends Node

var wave = load("res://wave.tscn")

var spawned = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not spawned:
		if Input.is_action_just_released("mouseClick"):
			var instance = wave.instantiate()
			instance.position = get_viewport().get_mouse_position()
			add_child(instance)
			spawned = true
