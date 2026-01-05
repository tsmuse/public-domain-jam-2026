class_name LoadingScreen
extends Control

## Used by the SceneManager to display transitions and loading progress. 
## Like the SceneManager, this was initially based on the Bacon and Games implimentation

signal transition_in_complete

@onready var progress_bar := $HBoxContainer/ProgressBar
@onready var anim_player := $AnimationPlayer
@onready var timer := $Timer

var starting_animation_name: String

## Hides progress bar on startup, it gets revealed if loading takes too long
func _ready():
	progress_bar.visible = false

## called by SceneManager to start the "in" transition
func start_transition(animation_name:String):
	if !anim_player.has_animation(animation_name):
		push_warning("'%s' animation does not exist" % animation_name)
		animation_name = "fade_to_black"
	
	starting_animation_name = animation_name
	anim_player.play(animation_name)
	# if timer fires before we finish loading this will show the progress bar
	timer.start()

## called by the SceneManager to play the outro to the transition once the content is loaded
func finish_transition():
	if timer:
		timer.stop()
	# construct the second half of the transition's animation name
	var ending_animation_name:String = starting_animation_name.replace("to","from")
	
	if !anim_player.has_animation(ending_animation_name):
		push_warning("'%s' animation does not exist" % ending_animation_name)
		ending_animation_name = "fade_from_black"
	anim_player.play(ending_animation_name)
	await anim_player.animation_finished
	queue_free()

## called at the end of "in" transitions via the method track in the animation
## lets the SceneManager know that the screen is obscured and loading of the incoming scene can begin
func report_midpoint():
	transition_in_complete.emit()

## if loading takes long enough, the loading bar becomes visible
func _on_timer_timeout():
	progress_bar.visible = true

func update_bar(val:float):
	progress_bar.value = val
