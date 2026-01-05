class_name SceneRegistry
extends Node

# This is an interesting pattern, I'm not sure I love it, but it's probably easier than trying to 
# infer this info by reading a folder every time the game loads? The original author isn't sure
# about this bit and neither I am, but I'll use it for now for lack of a better idea

const menus = {
	"StartScreen": "res://Menus/start_screen.tscn",
	"SettingsMenu": "res://Menus/settings_menu.tscn",
	"ConfirmQuit": "res://Menus/confirm_quit.tscn",
}

const levels = {
	"test": "res://Levels/test_level.tscn",
}
