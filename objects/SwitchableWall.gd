extends StaticBody2D

export var TIME : float = 4.0
export var INVERSED = false

var flipped = true

func _ready():
	flipped = !INVERSED
	set_collision_layer_bit(0, flipped)
	visible = flipped
	
	start_timer(TIME)

# start timer with given time
func start_timer(wait_time):
	$Timer.start(wait_time)

func _on_Timer_timeout():
	flipped = !flipped
	set_collision_layer_bit(0, flipped)
	visible = flipped
