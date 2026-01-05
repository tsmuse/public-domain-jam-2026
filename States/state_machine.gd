class_name StateMachine
extends Node

## This is the most basic finite state machine. I decided to leave it like this so I could use it as a base class for more specific state machines, like movement controllers, which have less generaliziable features. This machine and the associated State class support the Hierarchical FSM pattern via inheritence and this base class should allow for easy creation of Concurrent State Machines where needed.
## I wanted to make this as generic as possible but I haven't had any need (yet) for a state machine this complex that isn't for a player character or an AI controlled character. So this is generic, but it still assumes you're attaching this to a CharacterBody2D and that you will have an animatable sprite to trigger animations with. If I need a more generic than this State Machine I'll probably have to create a different base class due to the limitations of GDScript and my own abilites. But this should work as a base for animated characters.
## Based on the very nice basic state machine by theshaggydev 
## (https://github.com/theshaggydev/the-shaggy-dev-projects/blob/main/projects/godot-4/state-machines)
## and the State patterns referred to in https://gameprogrammingpatterns.com/state.html (which the above implimentation references too)

## The state the machine should always start in
@export var initial_state:State

## internal - This is the current state the machine is in
var _current_state: State

## Sets up the StateMachine. The object using the state machine passes itself into this function so it can be shared with all the States
## This setup requires all states to be in the Scene Tree as children of the StateMachine Node. This makes state management more Godot like 
func init(parent: CharacterBody2D, animation: AnimatedSprite2D): # animation will need to be turned into a SpineSprite when I start using Spine animations
	for child in get_children():
		child.parent = parent
		child.animation = animation
	
	_change_state(initial_state)

## internal - Called when a new state change is requested. 
func _change_state(new_state: State) -> void:
	if _current_state:
		_current_state.exit()
	_current_state = new_state
	_current_state.enter()
	
## The Object using the StateMachine needs to call each of these functions in their coresponding lifecycle functions

## This function needs to be called in the _physics_process function
func process_physics(delta:float)-> void:
	var new_state = _current_state.process_physics(delta)
	if new_state:
		_change_state(new_state)

## This function needs to be called in the _unhandled_input function
func process_input(evt:InputEvent) -> void:
	var new_state = _current_state.process_input(evt)
	if new_state:
		_change_state(new_state)

## This function needs to be called in the _process function
func process_frame(delta:float) -> void:
	var new_state = _current_state.process_frame(delta)
	if new_state:
		_change_state(new_state)
