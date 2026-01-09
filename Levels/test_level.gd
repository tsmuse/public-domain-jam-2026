extends Node2D

@onready var vel_label = $UI/velocity
@onready var player_pos = $UI/player_pos

@onready var speed_label = $UI/Settings/HBoxContainer/VBoxContainer/maxSpeed
@onready var acel_label = $UI/Settings/HBoxContainer/VBoxContainer/maxAcel
@onready var decel_label = $UI/Settings/HBoxContainer/VBoxContainer/maxDecel
@onready var turn_label = $UI/Settings/HBoxContainer/VBoxContainer/turnSpeed

@onready var jumph_label = $UI/Settings/HBoxContainer/VBoxContainer2/jumpHeight
@onready var jumpd_label = $UI/Settings/HBoxContainer/VBoxContainer2/jumpDuration
@onready var downg_label = $UI/Settings/HBoxContainer/VBoxContainer2/downGravity
@onready var aa_label = $UI/Settings/HBoxContainer/VBoxContainer2/airAccel
@onready var ab_label = $UI/Settings/HBoxContainer/VBoxContainer2/airBreak
@onready var ac_label = $UI/Settings/HBoxContainer/VBoxContainer2/airControl
@onready var vh_label = $UI/Settings/HBoxContainer/VBoxContainer2/variableHeight
@onready var vhcut_label = $UI/Settings/HBoxContainer/VBoxContainer2/variableHeightCutoff
@onready var airjump_label = $UI/Settings/HBoxContainer/VBoxContainer2/airJump
@onready var airjumpcount_label = $UI/Settings/HBoxContainer/VBoxContainer2/airJumpCount


@onready var coyote_label = $UI/Settings/HBoxContainer/VBoxContainer3/coyoteTime
@onready var jumpb_label = $UI/Settings/HBoxContainer/VBoxContainer3/jumpBuffer
@onready var tv_label = $UI/Settings/HBoxContainer/VBoxContainer3/terminalVelocity

@onready var player = $Player
@onready var controller = $Player/PlayerController
@onready var pusher = $Pusher

var last_velocity := Vector2.ZERO

func _ready():
	vel_label.text = "Velocity: (%2.3f,%2.3f)" % [player.velocity.x, player.velocity.y]
	player_pos.text = "player pos (%2.3f,%2.3f)" % [player.position.x, player.position.y]
	
	speed_label.text = "Max Speed: %s" % controller.max_speed
	acel_label.text = "Max Acel: %s" % controller.max_accel
	decel_label.text = "Max Decl: %s" % controller.max_decel
	turn_label.text = "Turn Speed: %s" % controller.turn_speed
	
	jumph_label.text = "Jump Height: %s px" % controller.jump_height
	jumpd_label.text = "Jump Duration: %s sec" % controller.jump_duration
	downg_label.text = "Down Gravity: %s x G" % controller.down_gravity
	aa_label.text = "Air Accel: %s" % controller.max_air_accel
	ab_label.text = "Air Break: %s" % controller.air_brake
	ac_label.text = "Air Control: %s" % controller.air_control
	vh_label.text = "Variable Height Jumps: %s" % controller.variable_height
	vhcut_label.text = "Variable Height Cutoff: %s" % controller.variable_height_cutoff
	airjump_label.text = "Air Jumps: %s" % controller.air_jump
	airjumpcount_label.text = "Concurent Air Jumps: %s" % controller.concurent_air_jumps
	
	coyote_label.text = "Coyote Time: %s" % controller.coyote_time
	jumpb_label.text = "Jump Buffer: %s" % controller.jump_buffer
	tv_label.text = "Terminal Velocity: %s x G" % controller.terminal_velocity
	

func _process(_delta):
	vel_label.text = "Velocity: (%2.3f,%2.3f)" % [player.velocity.x, player.velocity.y]
	player_pos.text = "player pos (%2.3f,%2.3f)" % [player.position.x, player.position.y]
	
	# enable these if you're actually changing them while the game it running
	#speed_label.text = "Max Speed: %s" % controller.max_speed
	#acel_label.text = "Max Acel: %s" % controller.max_accel
	#decel_label.text = "Max Decl: %s" % controller.max_decel
	#turn_label.text = "Turn Speed: %s" % controller.turn_speed
	#
	#jumph_label.text = "Jump Height: %s px" % controller.jump_height
	#jumpd_label.text = "Jump Duration: %s sec" % controller.jump_duration
	#downg_label.text = "Down Gravity: %s x G" % controller.down_gravity
	#aa_label.text = "Air Accel: %s" % controller.max_air_accel
	#ab_label.text = "Air Break: %s" % controller.air_brake
	#ac_label.text = "Air Control: %s" % controller.air_control
	#vh_label.text = "Variable Height Jumps: %s" % controller.variable_height
	#vhcut_label.text = "Variable Height Cutoff: %s" % controller.variable_height_cutoff
	#airjump_label.text = "Air Jumps: %s" % controller.air_jump
	#airjumpcount_label.text = "Concurent Air Jumps: %s" % controller.concurent_air_jumps
	#
	#coyote_label.text = "Coyote Time: %s" % controller.coyote_time
	#jumpb_label.text = "Jump Buffer: %s" % controller.jump_buffer
	#tv_label.text = "Terminal Velocity: %s x G" % controller.terminal_velocity
	

func _physics_process(delta: float) -> void:
	pass
	#pusher.position.x += pusher.speed * delta
