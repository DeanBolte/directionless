extends KinematicBody2D

export var MAX_VER_VELOCITY = 1000
export var MAX_HOR_VELOCITY = 400
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
var facing = 0
var dashCoolDown = 0
var state = MOVE
var gravityDir = Vector2.DOWN

func _physics_process(delta):
	match state:
		MOVE: # player movement control
			move_state(delta)
		DASH:
			dash_state(delta)
	
	# apply gravity
	velocity += gravityDir * GRAVITY * delta
	
	# move player
	velocity = move_and_slide(velocity, gravityDir.rotated(PI))

func move_state(delta):
	# player input
	var move = sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	if move != 0:
		facing = move
	
	# horizontal movement
	if move != 0:
		velocity += gravityDir.rotated(-PI/2) * move * ACCELERATION * delta
	var horVelocity = velocity.project(gravityDir.rotated(PI/2))
	if horVelocity.length() > MAX_HOR_VELOCITY:
		# slow player down if they're going above speed limit
		var horLimitVector = MAX_HOR_VELOCITY * gravityDir.rotated(PI/2)
		velocity -= horVelocity - horLimitVector * horVelocity.sign() * horLimitVector.sign()
	var verVelocity = velocity.project(gravityDir.rotated(PI))
	if verVelocity.length() > MAX_VER_VELOCITY:
		# slow player down if they're going above speed limit
		var verLimitVector = MAX_VER_VELOCITY * gravityDir.rotated(PI)
		velocity -= verVelocity - verLimitVector * verVelocity.sign() * verLimitVector.sign()
	
	# dash
	if Input.is_action_just_pressed("ui_dash") && dashCoolDown <= 0:
		# if wall sliding reverse dash
		if is_on_wall():
			facing *= -1
		
		# reset dash cooldown and wall jumps
		dashCoolDown = DASH_COOLDOWN
		
		# change state
		state = DASH
		AnimationPlayer.play("Dash")
		$SoundDash.play()
	elif dashCoolDown > 0:
		dashCoolDown -= delta
	
	# jumping and friction
	if is_on_floor():
		# apply friction to player on ground
		if move == 0:
			velocity = lerp(velocity, Vector2.ZERO, FRICTION)
		
		# jump
		if Input.get_action_strength("ui_jump"):
			velocity -= JUMP_STRENGTH * gravityDir
			$SoundJump.play()
		
	else:
		if is_on_wall():
			if Input.is_action_just_pressed("ui_jump"):
				velocity += JUMP_STRENGTH * gravityDir.rotated(PI)
				velocity += -move * JUMP_STRENGTH * gravityDir.rotated(-PI/2)
				$SoundJump.play()

func dash_state(delta):
	velocity = gravityDir.rotated(-PI/2) * DASH_SPEED * facing

func dash_end():
	state = MOVE

func restart():
	# death sound
	$SoundDeath.play()
	
	# reset gravity
	gravityDir = Vector2.DOWN
	
	# reset position
	var respawnPoint = get_tree().root.get_child(0).get_node("PlayerSpawn").position
	self.position = respawnPoint

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

func _on_KillZoneDetector_body_entered(body):
	restart()

func _on_EndDetector_area_entered(area):
	get_tree().change_scene("res://scenes/TheEnd.tscn")
