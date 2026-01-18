class_name Run3p
extends ControllerState

@export_category("Related States")
@export var idle_state: ControllerState

## Called when the State is loaded
func enter() -> void:
	print("Run: Entering Run")
	# pass

## Called when the State is unloaded
func exit() -> void:
	pass

## Called by the parent's _unhandled_input lifecycle function. Any logic dealing with player input goes here. 
func process_input(_evt: InputEvent) -> State:
	return null

## Called by the parent's _process lifecycle function. Any non-physics related logic goes here. 
func process_frame(_delta: float) -> State:
	return null

## Called by the parent's _physics_process lifecycle function. Any logic that uses the physics engine goes here.
func process_physics(delta: float)-> State:
	var velocity := parent.velocity
	var direction := controller.get_movement_direction()
	var desired_velocity := direction * controller.max_speed
	var acceleration := controller.max_accel 
	var deceleration := controller.max_decel 
	var turn_speed := controller.turn_speed 
	var max_speed_change := deceleration * delta
	
	# Set Sprite facing direction on x-axis
	parent.sprite.flip_h = sign(direction.x) > 0
	# Set Sprite facing direction on y-axis when I have a sprite for that
	
	# if the player is moving
	# if the player is changing direction
	if sign(direction.x) != sign(velocity.x) or sign(direction.y) != sign(velocity.y):
		max_speed_change = controller.turn_speed * delta
	else:
		max_speed_change = acceleration * delta
	
	velocity = velocity.move_toward(desired_velocity, max_speed_change)
	parent.velocity = velocity
	parent.move_and_slide()
	
	return null
