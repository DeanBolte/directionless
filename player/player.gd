extends KinematicBody2D

export var MAX_VELOCITY = 400
export var ACCELERATION = 5000
export var FRICTION = 0.3
export var AIR_FRICTION = 0.1
export var JUMP_STRENGTH = 500
export var MIN_JUMP_MODIFIER = 2
export var GRAVITY = 1000
export var DASH_SPEED = 1500
export var DASH_COOLDOWN = 0.4

onready var AnimationPlayer = $AnimationPlayer

enum { MOVE, DASH, RESTARTING }

var velocity = Vector2.ZERO
var facing = Vector2.RIGHT
var dashCoolDown = 0
var state = MOVE

func _physics_process(delta):
	match state:
		MOVE: # player movement control
			move_state(delta)
		DASH:
			dash_state(delta)
	
	# apply gravity
	velocity.y += GRAVITY * delta
	
	# move player
	velocity = move_and_slide(velocity, Vector2.UP)

func move_state(delta):
	# player input
	var hmove = sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	var vmove = sign(Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	if hmove != 0:
		facing.x = hmove
	if vmove != 0:
		facing.y = vmove
	
	# restart game
	if Input.get_action_strength("ui_restart"):
		restart()
	
	# horizontal movement
	if abs(velocity.x) < MAX_VELOCITY:
		if hmove != 0:
			velocity.x += hmove * ACCELERATION * delta
	else:
		# slow player down if they're going above speed limit
		velocity.x -= sign(velocity.x) * ACCELERATION * delta
	
	# dash
	if Input.is_action_just_pressed("ui_dash") && dashCoolDown <= 0:
		dashCoolDown = DASH_COOLDOWN
		state = DASH
		AnimationPlayer.play("Dash")
	elif dashCoolDown > 0:
		dashCoolDown -= delta
	
	if is_on_floor():
		# apply friction to player on ground
		if hmove == 0:
			velocity.x = lerp(velocity.x, 0, FRICTION)
		
		# jump
		if Input.get_action_strength("ui_jump"):
			velocity.y = -JUMP_STRENGTH
	else:
		# apply friction to player in air
		velocity.x = lerp(velocity.x, 0, AIR_FRICTION)
		
		# cancel jump
		if Input.is_action_just_released("ui_jump") && velocity.y < -JUMP_STRENGTH/MIN_JUMP_MODIFIER:
			velocity.y = -JUMP_STRENGTH/MIN_JUMP_MODIFIER

func dash_state(delta):
	velocity.x = DASH_SPEED * facing.x

func dash_end():
	state = MOVE

func restart():
	get_tree().change_scene("res://scenes/Scene_1.tscn")

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
