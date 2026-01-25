extends Node2D
class_name Measure

@export var despair_rect_start:Vector2i = Vector2i(0,-16) 
@export var despair_rect_length := 10
@export var despair_rect_height := 80

var notes:= self.get_children()

func _ready() -> void:
	pass
