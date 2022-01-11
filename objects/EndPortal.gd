extends Area2D

export (NodePath) var Key0Path
export (NodePath) var Key1Path
export (NodePath) var Key2Path
export (NodePath) var Key3Path

onready var Collision = $CollisionShape2D
onready var Key0 = get_node(Key0Path)
onready var Key1 = get_node(Key1Path)
onready var Key2 = get_node(Key2Path)
onready var Key3 = get_node(Key3Path)

var activated = true

func _physics_process(delta):
	activated = Key0.activated && Key1.activated && Key2.activated && Key3.activated
	
	if activated:
		rotate(PI * delta)
	
	Collision.disabled = !activated
	visible = activated
