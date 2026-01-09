class_name PlayerController
extends StateMachine

# The PlayerController takes the base StateMachine and includes player interaction specific methods and properties to create a single node that can control how a character responds to player input

@export_category("Movement")
## The max speed this character can move (bigger == faster)
@export_range(10,10000,10) var max_speed := 1000.0
 
## How fast the character hits the max speed (bigger == less time to max speed)
@export_range(10,5000,10) var max_accel := 500.0

## How fast the character comes to a stop when the player stops pressing the button (bigger == less time to complete stop)
@export_range(0,5000, 10) var max_decel := 2000.0

## How quickly the character stops moving the previous direction when a player changes direction (bigger == less drift, more responsive turns)
@export_range(100,10000, 10) var turn_speed := 2000.0

@export_category("Jumping")
## The max height of the jump in pixels (bigger == higher jump)
@export_range(1,10000,0.5) var jump_height := 100.0

## How long it takes to hit the jump height in seconds (bigger == slower jump)
@export_range(0.01,1000,0.01) var jump_duration := 0.5

## Gravity multiplier for falling out of the peak of jumps. (bigger == faster falling than jumping)
@export_range(1,20, 0.05) var down_gravity := 5.0

## The max speed this character can move while in the air. This is the in-air version of Max Accel
@export_range(0,5000,10) var max_air_accel := 100.0

## How fast the character coems to a stop while in the air. This is the in-air version of Max Decel
@export_range(0,5000,10) var air_brake := 100.0

## How quickly the character stops moving the previous direction in the air. This is the in-air version of Turn Speed
@export_range(0,10000,10) var air_control := 100.0

## Enables variable height jumping aka the jump is cut short when the player releases the jump button
@export var variable_height := false

## Required Variable Height to be true. Applies extra gravity multiplier when player lets go of jump button to ensure some portion of the original jump is always performed (bigger == more responsive jump clipping)
@export_range(1,20,0.05) var variable_height_cutoff := 10.0

## Enabled jumping while in the air
@export var air_jump := false

## The number of times the player can Air Jump before they have to touch the ground (1 == double jump)
@export var concurent_air_jumps := 1

@export_category("Assists")
## The amount of time the player has while technically "in the air" to make a valid jump
@export_range(0,20,0.1) var coyote_time := 0.5

## The amount of time the player can press a jump early and still have a jump trigger when they land
@export_range(0,10,0.1) var jump_buffer := 0.5

## This is the maximum velocity the player can hit while falling, as a multiple of gravity
@export_range(1,50,0.5) var terminal_velocity := 10.0

var player_jumping := false
var coyote_time_counter := 0.0
var jump_buffering := false
var jump_buffer_counter := 0.0
var air_jumps_count := 0

func init(parent: CharacterBody2D, animation: AnimatedSprite2D):
	super(parent, animation)
	
	# register states
	for child in get_children():
		child.controller = self
	

func get_movement_direction() -> Vector2:
	return Input.get_vector("player_left","player_right","player_up","player_down")

func wants_to_jump() -> bool:
	return Input.is_action_just_pressed("player_jump")

func wants_to_action() -> bool:
	return Input.is_action_just_pressed("player_action")
