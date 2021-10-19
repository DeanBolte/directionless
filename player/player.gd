extends KinematicBody2D

export var MAX_VELOCITY = 400
export var ACCELERATION = 5000
export var FRICTION = 0.3
export var AIR_FRICTION = 0.05
export var JUMP_STRENGTH = 500
export var MIN_JUMP_MODIFIER = 2
export var GRAVITY = 1000

var velocity = Vector2.ZERO

func _physics_process(delta):
	var move = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# horizontal movement
	if move != 0:
		velocity.x += move * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -MAX_VELOCITY, MAX_VELOCITY)
	
	if is_on_floor():
		# apply friction to player on ground
		if move == 0:
			velocity.x = lerp(velocity.x, 0, FRICTION)
		
		# jump
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_STRENGTH
	else:
		# cancel jump
		if Input.is_action_just_released("ui_up") && velocity.y < -JUMP_STRENGTH/MIN_JUMP_MODIFIER:
			velocity.y = -JUMP_STRENGTH/MIN_JUMP_MODIFIER
		
		# apply friction to player in air
		if move == 0:
			velocity.x = lerp(velocity.x, 0, AIR_FRICTION)
	
	# apply gravity
	velocity.y += GRAVITY * delta
	
	# move player
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_RoomDetector_area_entered(area):
	var camera = $Camera2D
	var collision_shape = area.get_node("CollisionShape2D")
	var room_size = collision_shape.shape.extents*2
	var view_size = get_viewport_rect().size
	
	# resize the camera zoom
	var zoomScale = room_size.x / view_size.x
	var zoomScaleAlt = room_size.y / view_size.y
	camera.set_zoom(Vector2(min(zoomScale, zoomScaleAlt), min(zoomScale, zoomScaleAlt)))
	
	# set the camera limits
	camera.limit_top = collision_shape.global_position.y - room_size.y/2
	camera.limit_left = collision_shape.global_position.x - room_size.x/2
	
	camera.limit_bottom = camera.limit_top + room_size.y
	camera.limit_right = camera.limit_left + room_size.x
