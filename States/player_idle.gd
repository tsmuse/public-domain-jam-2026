class_name Idle
extends ControllerState

@export_category("Related States")
@export var run_state: ControllerState
@export var jump_state: ControllerState
@export var fall_state: ControllerState

## Called when the State is loaded
func enter() -> void:
	print("Idle: Entering Idle State")
	# pass

## Called when the State is unloaded
func exit() -> void:
	pass

## Called by the parent's _unhandled_input lifecycle function. Any logic dealing with player input goes here. 
func process_input(_evt: InputEvent) -> State:
	if controller.wants_to_jump():
		if parent.is_on_floor():
			return jump_state
	elif controller.get_movement_direction() != Vector2.ZERO:
		return run_state
	elif controller.wants_to_action():
		parent.fire_hookshot()
	return null

## Called by the parent's _process lifecycle function. Any non-physics related logic goes here. 
func process_frame(_delta: float) -> State:
	return null

## Called by the parent's _physics_process lifecycle function. Any logic that uses the physics engine goes here.
func process_physics(delta: float)-> State:
	# Handling any left over movement if there is accel/decel set
	var velocity = parent.velocity
	var on_floor = parent.is_on_floor()
	var desired_velocity := Vector2.ZERO
	var acceleration = controller.max_accel if on_floor else controller.max_air_accel
	var deceleration = controller.max_decel if on_floor else controller.air_brake
	var turn_speed = controller.turn_speed if on_floor else controller.air_control
	var max_speed_change = deceleration * delta
	
	# Add in gravity, it's important
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	velocity.x = move_toward(velocity.x, desired_velocity.x, max_speed_change)
	parent.velocity = velocity
	parent.move_and_slide()
	
	if not on_floor:
		return fall_state
	
	return null
