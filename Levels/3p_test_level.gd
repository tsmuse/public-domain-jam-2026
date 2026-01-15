extends Node2D

@onready var vel_label = $UI/velocity
@onready var player_pos = $UI/player_pos

@onready var speed_label = $UI/Settings/HBoxContainer/VBoxContainer/maxSpeed
@onready var acel_label = $UI/Settings/HBoxContainer/VBoxContainer/maxAcel
@onready var decel_label = $UI/Settings/HBoxContainer/VBoxContainer/maxDecel
@onready var turn_label = $UI/Settings/HBoxContainer/VBoxContainer/turnSpeed

@onready var jumph_label = $UI/Settings/HBoxContainer/VBoxContainer2/jumpHeight


@onready var player := $Player
@onready var controller := $Player/PlayerController

@onready var despair := $TileLayers/Despair
@onready var despair_timer := $DespairTimer

var composer_progress := 0.0
var despair_count := 0
var despair_source_id := 0
var despair_atlas_coord := Vector2i(5,5)
var despair_start_coord := Vector2i(-5,-5)
var despair_next_line := Vector2i(166,72)
var despair_should_grow := false
var clear_despair_around_player := false
var despair_to_clear_w_player := Vector2i(0,0)

var last_velocity := Vector2.ZERO

func _ready():
	vel_label.text = "Velocity: (%2.3f,%2.3f)" % [player.velocity.x, player.velocity.y]
	player_pos.text = "player pos (%2.3f,%2.3f)" % [player.position.x, player.position.y]
	
	speed_label.text = "Max Speed: %s" % controller.max_speed
	acel_label.text = "Max Acel: %s" % controller.max_accel
	decel_label.text = "Max Decl: %s" % controller.max_decel
	turn_label.text = "Turn Speed: %s" % controller.turn_speed
	
	jumph_label.text = "Composer Progress: %s" % composer_progress
	
	

func _process(delta):
	vel_label.text = "Velocity: (%2.3f,%2.3f)" % [player.velocity.x, player.velocity.y]
	player_pos.text = "player pos (%2.3f,%2.3f)" % [player.position.x, player.position.y]
	
	if despair_should_grow:
		var far_x = despair_start_coord.x + despair_next_line.x
		var far_y = despair_start_coord.y + despair_next_line.y
		# draw a line from start_coord to (start_coord.x + next_line.x, start_coord.y)
		for i in range(despair_next_line.x):
			# todo: check all the tiles around and fill in blank tile instead
			despair.set_cell(Vector2i(despair_start_coord.x + i, despair_start_coord.y), despair_source_id, despair_atlas_coord)
			despair_count += 1
		# draw a line from (start_coord.x + next_line.x, start_coord.y) to (start_coord.x + next_line.x, start_coord.y + next_line.y)
		for i in range(despair_next_line.y):
			# todo: check all the tiles around and fill in blank tile instead
			despair.set_cell(Vector2i(far_x, despair_start_coord.y + i), despair_source_id, despair_atlas_coord)
			despair_count += 1
		# draw a line from (start_coord.x + next_line.x, start_coord.y + next_line.y) to (start_coord.x, start_coord.y + next_line.y)
		for i in range(despair_next_line.x):
			# todo: check all the tiles around and fill in blank tile instead
			despair.set_cell(Vector2i(far_x - i, far_y), despair_source_id, despair_atlas_coord)
			despair_count += 1
		# draw a line from (start_coord.x + next_line.x, start_coord.y + next_line.y) to start_coord
		for i in range(despair_next_line.y):
			# todo: check all the tiles around and fill in blank tile instead
			despair.set_cell(Vector2i(despair_start_coord.x, far_y - i), despair_source_id, despair_atlas_coord)
			despair_count += 1

		despair_start_coord = despair_start_coord + Vector2i(1,1)
		despair_next_line = despair_next_line - Vector2i(2,2)
		despair_should_grow = false
	
	composer_progress += (17.0 - (despair_count * 0.01)) * delta
	jumph_label.text = "Composer Progress: %s" % composer_progress
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
	if player.despair_detector.has_overlapping_bodies():
		despair_to_clear_w_player = despair.local_to_map(player.global_position)
		_clear_around_player(despair_to_clear_w_player)
	


func _on_despair_timer_timeout() -> void:
	despair_should_grow = true

func _clear_around_player(coord) -> void:
	print("Clearing despair around player standing at (%s)" % coord)
	despair.erase_cell(coord)
	despair.erase_cell(Vector2i(coord.x -1, coord.y))
	despair.erase_cell(Vector2i(coord.x + 1, coord.y))
	despair.erase_cell(Vector2i(coord.x, coord.y - 1))
	despair.erase_cell(Vector2i(coord.x, coord.y + 1))
	
