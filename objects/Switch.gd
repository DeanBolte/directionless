extends StaticBody2D

export (Texture) var ButtonDepressed
export (Texture) var ButtonPressed
export (NodePath) var KeyPath
export (int) var Index = 0

onready var SwitchSprite = $Sprite
onready var ButtonTop = $TopCollisionShape
onready var Key = get_node(KeyPath)

var activated = false

func _physics_process(delta):
	if activated:
		SwitchSprite.texture = ButtonPressed
		ButtonTop.disabled = true
	else:
		SwitchSprite.texture = ButtonDepressed
		ButtonTop.disabled = false
	
	Key.activated = activated

func _on_PlayerDetector_body_shape_entered(body_id, body, body_shape, area_shape):
	activated = true
