class_name SettingsMenu 
extends Node

# Opening this screen pauses the game. Should this be an option for games where time is part of the challenge?

signal language_changed(language: String)

@onready var music_slider:HSlider = %MusicSlider
@onready var sfx_slider:HSlider = %SFXSlider
@onready var language_dropdown:OptionButton = %LanguageDropdown
@onready var close_button:Button = %CloseButton
@onready var save_button:Button = %SaveButton
@onready var quit_button:Button = %QuitButton
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs

func _ready():
	# load or create file with these saved preferences
	user_prefs = UserPrefs.load_or_create()
	
	# if you want the option to save the game from here, replace this line with
	# logic that asures the game is in a saveable state
	save_button.visible = false
	
	# if youw ant the option to quit the game from here, replace this line with
	# logic that asures the game is in a place it's safe to quit
	quit_button.visible = true
	
	if music_slider:
		music_slider.value = user_prefs.music_volume
	if sfx_slider:
		sfx_slider.value = user_prefs.sfx_volume
	if language_dropdown:
		language_dropdown.selected = user_prefs.language


func _process(delta):
	# listening for the default UI cancel action, change this if you need to
	if Input.is_action_just_pressed("ui_cancel"):
		close_settings()

func close_settings():
	queue_free()

func _on_close_button_pressed():
	close_settings()

func _on_save_button_pressed():
	# put save logic here. The inspireation for this boilerplate suggests doing it as a global function
	# in Globals, like a Globals.user_save.save_all_game_data() function
	print("Save button pressed!")

func _on_quit_button_pressed():
	SceneManager.swap_scenes(SceneRegistry.menus["ConfirmQuit"], get_tree().root, self, "no_transition")
