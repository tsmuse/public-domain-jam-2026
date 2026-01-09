class_name Jump
extends ControllerState

@export_category("Related States")
@export var idle_state: ControllerState
@export var run_state: ControllerState
@export var fall_state: ControllerState

var do_a_double := false
var new_gravity  : float
var initial_jump_velocity : float


## Called when the State is loaded
func enter() -> void:
	print("Jump: Entering Jump")
	controller.player_jumping = true # setting this to be used by the fall state
	
	# Manage the jump buffer
	if controller.jump_buffering:
		controller.jump_buffering = false
		controller.jump_buffer_counter = 0.0
		
	# This happens right away so the physics loop can just slow the player down each tick
	new_gravity = 2 * controller.jump_height / pow(controller.jump_duration, 2)
	initial_jump_velocity = sqrt(2 * new_gravity * controller.jump_height)
	#print("Jump: gravity for this jump: %s" % new_gravity)
	#print("Jump: launch V for this jump: %s" % initial_jump_velocity)
	parent.velocity.y = -initial_jump_velocity # negating it here becuase y<0 is up in Godot

## Called when the State is unloaded
func exit() -> void:
	pass

## Called by the parent's _unhandled_input lifecycle function. Any logic dealing with player input goes here. 
func process_input(_evt: InputEvent) -> State:
	if controller.wants_to_jump():
		if controller.air_jump and controller.air_jumps_count < controller.concurent_air_jumps:
			controller.air_jumps_count += 1
			parent.velocity.y = -initial_jump_velocity # this is a new jump. eveything else proceeds as normal
			print("Jump: Double Jumped!")
		else:
			print("Jump: Random Jump requested")
	elif controller.wants_to_action():
		parent.fire_hookshot()
	return null

## Called by the parent's _process lifecycle function. Any non-physics related logic goes here. 
func process_frame(_delta: float) -> State:
	return null

## Called by the parent's _physics_process lifecycle function. Any logic that uses the physics engine goes here.
func process_physics(delta: float)-> State:
	var gravity := Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var velocity := parent.velocity
	var on_floor := parent.is_on_floor()
	var pressing_jump := Input.is_action_pressed("player_jump") if controller.variable_height else true
	# setting up for horizontal movement
	var direction_x := controller.get_movement_direction().x
	var desired_velocity := Vector2(direction_x, 0.0) * controller.max_speed
	var acceleration := controller.max_accel if on_floor else controller.max_air_accel
	var deceleration := controller.max_decel if on_floor else controller.air_brake
	var turn_speed := controller.turn_speed if on_floor else controller.air_control
	var max_speed_change := deceleration * delta
	
	# Jump
	if velocity.y >= 0:
		return fall_state # Falling modifiers are handled in the fall state
	if velocity.y < 0:
		#print("Jump: gravity applied this tick: %s" % (new_gravity * delta))
		if controller.variable_height and not Input.is_action_pressed("player_jump"):
			velocity.y += (new_gravity * controller.variable_height_cutoff) * delta
		else:
			velocity.y += new_gravity * delta
		#print("Jump: new velocity.y is: %s" % velocity.y)

	# if the player is moving
	if direction_x != 0:
		# if the player is changing direction
		if sign(direction_x) != sign(velocity.x):
			max_speed_change = controller.turn_speed * delta
		else:
			max_speed_change = acceleration * delta
	
	velocity.x = move_toward(velocity.x, desired_velocity.x, max_speed_change)	
	parent.velocity = velocity
	parent.move_and_slide()
	#I'm pretty sure the on_floor value will be the same even after the move_and_slide becuase it won't update until the next tick
	if on_floor and velocity.y >= 0:
		controller.player_jumping = false
		controller.air_jumps_count = 0
		return idle_state
	
	return null
