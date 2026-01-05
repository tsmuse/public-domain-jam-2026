extends Control

@onready var yes_button = %YesButton
@onready var no_button = %NoButton

func _on_yes_button_up():
	get_tree().quit()

func _on_no_button_up():
	queue_free()
