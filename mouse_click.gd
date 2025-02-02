extends Node

var wave = load("res://wave.tscn")

var waiting_for_wave = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('mouseClick') and not waiting_for_wave:
		waiting_for_wave = true
		var instance = wave.instantiate()
		instance.position = get_viewport().get_mouse_position()
		
		add_child(instance)

func wave_spawned():
	waiting_for_wave = false
