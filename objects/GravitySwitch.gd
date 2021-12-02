extends KinematicBody2D

onready var Player = get_tree().root.get_child(0).get_node("Player")

var origin = Vector2.ZERO
var velocity = Vector2.ZERO
var SPEED = 10000
var MAXIMUM_DISTANCE = 32

var pushDir = Vector2.ZERO
var active = false

func _ready():
	origin = position

func _physics_process(delta):
	var distanceVec = origin - position
	if distanceVec.length() < MAXIMUM_DISTANCE:
		velocity += pushDir * delta * 10
	else:
		Player.gravityDir = pushDir.normalized()
		pushDir = Vector2.ZERO
		active = false
	
	if active == false:
		velocity = distanceVec * 10
	
	velocity = move_and_slide(velocity)
	if active == false && get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if collision && collision.collider.is_class("KinematicBody2D"):
			pushDir = global_position - collision.collider.position
			if abs(pushDir.x) < abs(pushDir.y):
				pushDir.x = 0
			else:
				pushDir.y = 0
			
			active = true

