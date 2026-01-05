class_name State
extends Node

## This is the most basic State class to be used with the StateMachine.
## This class can be extended via inheritence to build the Hierarchical FSM pattern if needed.
## Each State needs to be attached to a child Node of the StateMachine Node in the Scene Tree to work. 
## References to Related States are created with an @export var and managed in the inspector.
##
## Based on the very nice basic state machine by theshaggydev 
## (https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-4/state-machines)
## and the State patterns referred to in https://gameprogrammingpatterns.com/state.html (which the above implimentation references too)

# I prefer to put my related states into a catagory
# @export_category("Related States")

## internal - The reference to the CharacterBody2D the using the StateMachine. This is set by the StateMachine on init. 
var parent:CharacterBody2D
## internal - The reference to the AnimatedSprite2D in the CharacterBody2D using the StateMachine. This is set by the StateMachine on init. 
var animation:AnimatedSprite2D # this will need to become a SpineSprite when I start using Spine animations

## Called when the State is loaded
func enter() -> void:
	pass

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
func process_physics(_delta: float)-> State:
	return null
