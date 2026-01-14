class_name Idle
extends ControllerState

@export_category("Related States")
@export var run_state: ControllerState


## Called when the State is loaded
func enter() -> void:
	print("Idle: Entering Idle State")
	# pass

## Called when the State is unloaded
func exit() -> void:
	pass

## Called by the parent's _unhandled_input lifecycle function. Any logic dealing with player input goes here. 
func process_input(_evt: InputEvent) -> State:
	if controller.get_movement_direction() != Vector2.ZERO:
		return run_state
	return null

## Called by the parent's _process lifecycle function. Any non-physics related logic goes here. 
func process_frame(_delta: float) -> State:
	return null

## Called by the parent's _physics_process lifecycle function. Any logic that uses the physics engine goes here.
func process_physics(delta: float)-> State:
	# Handling any left over movement if there is accel/decel set
	var velocity = parent.velocity

	var desired_velocity := Vector2.ZERO
	var acceleration = controller.max_accel 
	var deceleration = controller.max_decel 
	var turn_speed = controller.turn_speed 
	var max_speed_change = deceleration * delta
	
	velocity.x = move_toward(velocity.x, desired_velocity.x, max_speed_change)
	parent.velocity = velocity
	parent.move_and_slide()
	
	return null
