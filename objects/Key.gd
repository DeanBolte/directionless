extends StaticBody2D

export (Texture) var CubeSprite

var activated = false

func _ready():
	$Sprite.texture = CubeSprite

func _physics_process(delta):
	if activated:
		rotate(PI*delta)
		visible = true
	else:
		visible = false
