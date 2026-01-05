class_name StartScreen 
extends Control

const game_version := "0.0"

@onready var version_label := $MarginContainer/Version 

# Called when the node enters the scene tree for the first time.
func _ready():
	version_label.text = "v%s" % game_version


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_quit_button_up():
	get_tree().quit()

func _on_start_button_up():
	SceneManager.swap_scenes(SceneRegistry.levels["test"], get_tree().root, self, "fade_to_black")

func _on_settings_button_up():
	SceneManager.swap_scenes(SceneRegistry.menus["SettingsMenu"], get_tree().root, null, "no_transition")
