extends StaticBody2D

export var TIME : float = 4.0

func _ready():
	yield(get_tree().create_timer(TIME), "timeout")
	set_collision_layer_bit(0, false)
	visible = false
