class_name Run
extends ControllerState

@export_category("Related States")
@export var idle_state: ControllerState
@export var jump_state: ControllerState
@export var fall_state: ControllerState

## Called when the State is loaded
func enter() -> void:
	print("Run: Entering Run")
	# pass

## Called when the State is unloaded
func exit() -> void:
	pass

## Called by the parent's _unhandled_input lifecycle function. Any logic dealing with player input goes here. 
func process_input(_evt: InputEvent) -> State:
	if controller.wants_to_jump():
		var can_air_jump = controller.player_jumping and controller.air_jump and controller.air_jumps_count < controller.concurent_air_jumps 
		
		# This was the most readable way I could think to write this, even though it's an if elif with the same result in both branches
		if parent.is_on_floor():
			return jump_state
		elif can_air_jump:
			controller.air_jumps_count += 1
			return jump_state
		elif controller.coyote_time_counter < controller.coyote_time:
			return jump_state
		elif controller.jump_buffer > 0 and not controller.jump_buffering:
			controller.jump_buffering = true
	return null

## Called by the parent's _process lifecycle function. Any non-physics related logic goes here. 
func process_frame(_delta: float) -> State:
	return null

## Called by the parent's _physics_process lifecycle function. Any logic that uses the physics engine goes here.
func process_physics(delta: float)-> State:
	var velocity := parent.velocity
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	var terminal_velocity = gravity * controller.terminal_velocity
	var on_floor := parent.is_on_floor()
	var direction_x := controller.get_movement_direction().x
	var desired_velocity := Vector2(direction_x, 0.0) * controller.max_speed
	var acceleration := controller.max_accel if on_floor else controller.max_air_accel
	var deceleration := controller.max_decel if on_floor else controller.air_brake
	var turn_speed := controller.turn_speed if on_floor else controller.air_control
	var max_speed_change := deceleration * delta
	var falling_after_jump = controller.player_jumping
	
	# Update the Coyote Time Counter and Jump buffer
	if not on_floor:
		controller.coyote_time_counter += delta
		#print("Fall: Coyte Time in air: %s" % controller.coyote_time_counter)
		if controller.jump_buffering:
			controller.jump_buffer_counter += delta
	
	# Add in gravity, it's important
	if falling_after_jump:
		#print("Run: gravity: %s velocity.y: %s terminal_velocity: %s" % [gravity, velocity.y, terminal_velocity])
		if velocity.y >= terminal_velocity:
			velocity.y = terminal_velocity
		else:
			velocity.y += (gravity * controller.down_gravity) * delta 
	else:
		if velocity.y >= terminal_velocity:
			velocity.y = terminal_velocity
		else:
			velocity.y += gravity * delta 
	
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
	elif on_floor:
		controller.coyote_time_counter = 0.0
		if controller.jump_buffering and controller.jump_buffer_counter < controller.jump_buffer:
			print("Run: Jump Buffer Jump!")
			return jump_state
		
		return idle_state
	else:
		return fall_state
	
	return null
