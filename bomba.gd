extends Node2D

@onready var sprite := $Sprite2D
@onready var timer := $Timer

signal bomba_boom

func _ready() -> void:
	pass



func _on_timer_timeout() -> void:
	bomba_boom.emit(self)
