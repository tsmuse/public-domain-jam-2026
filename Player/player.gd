extends CharacterBody2D

@onready var controller := $PlayerController

var temp := AnimatedSprite2D.new()

func _ready():
	controller.init(self, temp)

func _physics_process(delta):
	controller.process_physics(delta)

func _unhandled_input(event):
	controller.process_input(event)

func _process(delta):
	controller.process_frame(delta)
