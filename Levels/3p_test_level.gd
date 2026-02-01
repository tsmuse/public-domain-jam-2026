extends Node2D

@onready var player := $Player
@onready var controller := $Player/PlayerController
@onready var start_level_pad := $StartClef
@onready var next_level_pad := $NextLevel

@onready var despair := $TileLayers/Despair
@onready var despair_timer := $DespairTimer

@onready var measures := $Measures

@onready var measure_label := %MeasuresCounter
@onready var beat_warning_1 := %Beat1
@onready var beat_warning_2 := %Beat2
@onready var beat_warning_3 := %Beat3
@onready var beat_warning_4 := %Beat4
@onready var success_text := %SuccessText
@onready var composer_resolve_bar := %ComposerResolve
@onready var game_over_panel := %GameoverPanel
# @onready var music_player := $MusicPlayer
@onready var music_group := $Music

@export var scene_number := 0

var composer_resolve := 100.0
var despair_count := 0
var despair_source_id := 1
var despair_atlas_coord := Vector2i(5,0)
var despair_start_coord :Vector2i
var despair_rect_size :Vector2i
var despair_rects_drawn := 0
var despair_should_grow := false
var clear_despair_around_player := false
var despair_to_clear_w_player := Vector2i(0,0)
var used_cells:Array[Vector2i]

var current_measure := 0
var measure_has_started := false
var bar: Node
var current_measure_complete := false
var level_complete := false
var level_fail := false
var game_overed := false
var total_levels := 5 # this is so hackey

var bomba_scn = preload("res://Tools/bomba.tscn")

var last_velocity := Vector2.ZERO
var static_monitoring := true

var measure_label_string := "Measure %s of %s"
var beat_warning_string_safe := "%s[font_size=\"32px\"]&[/font_size]"
var beat_warning_string_complete := "[color=aqua]%s[font_size=\"32px\"]&[/font_size][/color]"
var beat_warning_string_warn := "[shake rate=20.0 level=15 connected=1][color=crimson]%s[font_size=\"32px\"]&[/font_size][/color][/shake]"

var music_stream_path := "res://Music/lyric%s_%s.mp3"
var streams_for_phrase := []
var current_stream :AudioStreamPlayer

func _ready():
	# connect bomba signal
	player.player_dropped_bomba.connect(_on_player_dropped_bomba)
	
	# load music files
	# This doesn't work on the web and since this is a web submission, I had to do it a worse way that worked
	# for i in range(measures.get_children().size()):
	# 	var path = music_stream_path % [scene_number, i + 1]
	# 	streams_for_phrase.push_back(_load_mp3_stream(path))

	# load music files the hackey way that works in the webbrowser
	var music = music_group.get_children()
	for i in range(music.size()):
		streams_for_phrase.push_back(music[i])
	
	# complete_phrase = _load_mp3_stream("res://Music/lyric%s_complete.mp3" % scene_number)
	
	# set up UI that doesn't get refreshed every measure
	composer_resolve_bar.value = composer_resolve

	# setup the first bar
	_set_current_bar()
	
	# print("despair_start: %s, despair_rect_size: %s" % [despair_start_coord, despair_rect_size])

	
	
	
func _process(_delta):
	if not game_overed:
		if not level_complete and not level_fail:
			composer_resolve_bar.value = composer_resolve
			if composer_resolve <= 0.0:
				level_fail = true

		if not static_monitoring:
			_toggle_notes_detectors()
			static_monitoring = true
		if level_fail: 
			print("GAME OVER!!!")
			game_overed = true
			player.queue_free()
			current_measure_complete = false
			despair_should_grow = false
			despair_timer.stop()
			_flood_despair()
			game_over_panel.visible = true
		
		if level_complete:
			print("Level OVER!!!")
			# music_player.stream.loop = false
			current_measure_complete = false
			despair_should_grow = false
			despair_timer.stop()
			despair.clear()
			beat_warning_1.visible = false
			beat_warning_2.visible = false
			beat_warning_3.visible = false
			beat_warning_4.visible = false
			success_text.visible = true
			# pause here to play the music
			# if not music_player.playing:
				# music_player.stream = complete_phrase
				# music_player.play()
			if not current_stream.playing:
				current_stream = streams_for_phrase.back()
				current_stream.play()
				next_level_pad.visible = true
			
		if current_measure_complete:
			print("measure complete")
			print("current_measure before update: %s" % current_measure)
			if not current_stream.playing:
			# music_player.stream.loop = false
			# if not music_player.playing:
				current_measure += 1
				beat_warning_1.text = beat_warning_string_complete % 1
				beat_warning_2.text = beat_warning_string_complete % 2
				beat_warning_3.text = beat_warning_string_complete % 3
				beat_warning_4.text = beat_warning_string_complete % 4

				if current_measure == measures.get_children().size():
					level_complete = true
				else:
					current_measure_complete = false
					_set_current_bar()
					_start_notes_in_current_bar()

		
		if not current_measure_complete:
			# print("measure not complete")
			current_measure_complete = true
			for i in range(bar.get_children().size()):
				var current_note = bar.get_children()[i]
				if current_note.i_am_rest:
					pass
				elif not current_note.note_complete:
					current_measure_complete = false
					if not current_stream.playing:
						current_stream.play()
					break
		#print("test_area is overlapping despair? %s" % test_area.has_overlapping_bodies())

		used_cells = despair.get_used_cells()
		
		if despair_should_grow:
			# adjust composer resolve and update beat warning UI
			for i in range(bar.get_children().size()):
				var current_note = bar.get_children()[i]
				if current_note.i_am_rest:
					pass
				elif not current_note.note_complete and not current_note.note_processing:
					composer_resolve -= 1.0
					if current_note.beat == 1:
						beat_warning_1.text = beat_warning_string_warn % current_note.beat
					elif current_note.beat == 2:
						beat_warning_2.text = beat_warning_string_warn % current_note.beat
					elif current_note.beat == 3:
						beat_warning_3.text = beat_warning_string_warn % current_note.beat
					elif current_note.beat == 4:
						beat_warning_4.text = beat_warning_string_warn % current_note.beat
				elif not current_note.note_complete and current_note.note_processing:
					if current_note.beat == 1:
						beat_warning_1.text = beat_warning_string_safe % current_note.beat
					elif current_note.beat == 2:
						beat_warning_2.text = beat_warning_string_safe % current_note.beat
					elif current_note.beat == 3:
						beat_warning_3.text = beat_warning_string_safe % current_note.beat
					elif current_note.beat == 4:
						beat_warning_4.text = beat_warning_string_safe % current_note.beat
				elif current_note.note_complete:
					if current_note.beat == 1:
						beat_warning_1.text = beat_warning_string_complete % current_note.beat
					elif current_note.beat == 2:
						beat_warning_2.text = beat_warning_string_complete % current_note.beat
					elif current_note.beat == 3:
						beat_warning_3.text = beat_warning_string_complete % current_note.beat
					elif current_note.beat == 4:
						beat_warning_4.text = beat_warning_string_complete % current_note.beat


			# draw the despair tiles
			var far_x = despair_start_coord.x + despair_rect_size.x
			var far_y = despair_start_coord.y + despair_rect_size.y
			# draw top rect line from start_coord to (far_x, start_coord.y)
			_draw_despair_line(despair_start_coord, Vector2i(far_x, despair_start_coord.y))
			# draw a right rect line from (far_x, start_coord.y) to (far_x, far_y)
			_draw_despair_line(Vector2i(far_x, despair_start_coord.y), Vector2i(far_x,far_y))
			# draw a bottom line from (far_x, far_y) to (start_coord.x, far_y)
			_draw_despair_line(Vector2i(far_x,far_y), Vector2i(despair_start_coord.x, far_y))
			# draw a left line from (start_coord.x + next_line.x, start_coord.y + next_line.y) to start_coord
			_draw_despair_line(Vector2i(despair_start_coord.x,far_y), despair_start_coord)

			despair_start_coord = despair_start_coord + Vector2i(1,1)
			despair_rect_size = despair_rect_size - Vector2i(2,2)
			despair_rects_drawn += 1
			#print("despair_rects_drawn: %s" % despair_rects_drawn)
			despair_should_grow = false
			_toggle_notes_detectors()
			static_monitoring = false
		
		despair_count = despair.get_used_cells().size()

func _physics_process(_delta: float) -> void:
	if not game_overed:
		if player.despair_detector.has_overlapping_bodies():
			#var overlap = player.despair_detector.get_overlapping_bodies()[0]
			#print("Overlapping: %s" % overlap)
			despair_to_clear_w_player = despair.local_to_map(player.global_position)
			_clear_around_player(despair_to_clear_w_player)
		
		if player.despair_detector.has_overlapping_areas():
			var overlap = player.despair_detector.get_overlapping_areas()[0]
			#print("player overlapping some area: %s" % overlap)
			#print("is area start? %s" % overlap.get_collision_layer_value(4))
			# Player standing on start pad
			if overlap.get_collision_layer_value(4) and not measure_has_started:
				#print("Overlapping Start")
				_start_notes_in_current_bar()
				start_level_pad.visible = false
			if overlap.get_collision_layer_value(4) and next_level_pad.visible:
				print("goto NEXT LEVEL!!!")
				if scene_number + 1 > total_levels:
					SceneManager.swap_scenes(SceneRegistry.menus["StartScreen"], get_tree().root, self, "fade_to_black")	
				else:
					var next_level = "Lyric%s" % (scene_number + 1)
					SceneManager.swap_scenes(SceneRegistry.levels[next_level], get_tree().root, self, "fade_to_black")

func _flood_despair() -> void:
	for x in range(101):
		for y in range(51):
			despair.set_cell(Vector2i(x,y), despair_source_id, despair_atlas_coord) 

func _on_player_dropped_bomba(pos:Vector2) -> void:
	var real_bomba = bomba_scn.instantiate()
	real_bomba.global_position = pos
	real_bomba.bomba_boom.connect(_on_bomba_boom)
	self.add_child(real_bomba)

func _on_bomba_boom(bomba:Node2D) -> void:
	print("Bomba goes boom!")
	var bomba_tile_pos = despair.local_to_map(bomba.global_position)
	for x in range(-5,6,1):
		for y in range(-5,6,1):
			despair.erase_cell(Vector2i(bomba_tile_pos.x + x, bomba_tile_pos.y + y))
	#for i in range(4):
		#despair.erase_cell(bomba_tile_pos + Vector2i(i,i))
		#despair.erase_cell(bomba_tile_pos + Vector2i(-i,i))
		#despair.erase_cell(bomba_tile_pos + Vector2i(i,-i))
		#despair.erase_cell(bomba_tile_pos + Vector2i(-i,-i))
	bomba.queue_free()

func _toggle_notes_detectors() -> void:
	var notes = bar.get_children()
	for i in range(notes.size()):
		if not notes[i].i_am_rest:
			notes[i].toggle_detector()

func _start_notes_in_current_bar() -> void:
	measure_has_started = true
	despair_timer.start()
	var notes = bar.get_children()
	for i in range(notes.size()):
		if not notes[i].i_am_rest:  
			bar.get_children()[i].start_note()

func _set_current_bar() -> void:
	despair.clear()
	# set UI
	measure_label.text = measure_label_string % [current_measure + 1, measures.get_children().size()]
	beat_warning_1.text = beat_warning_string_safe % 1
	beat_warning_2.text = beat_warning_string_safe % 2
	beat_warning_3.text = beat_warning_string_safe % 3
	beat_warning_4.text = beat_warning_string_safe % 4

	# set bar used by process functions to find notes
	bar = measures.get_children()[current_measure]
	
	# set properties for despair to draw around the current measure
	despair_start_coord = bar.despair_rect_start
	despair_rect_size = Vector2i(bar.despair_rect_length, bar.despair_rect_height)
	despair_rects_drawn = 0

	# set music to the appropriate segment
	current_stream = streams_for_phrase[current_measure]
	current_stream.play()
		
		# music_player.stream = next_stream
		# music_player.play()
	
func _load_mp3_stream(path) -> AudioStreamMP3:
	var file = FileAccess.open(path, FileAccess.READ)
	var stream = AudioStreamMP3.new()
	stream.data = file.get_buffer(file.get_length())
	return stream

func _on_despair_timer_timeout() -> void:
	despair_should_grow = true

func _clear_around_player(coord) -> void:
	#print("Clearing despair around player standing at (%s)" % coord)
	despair.erase_cell(coord)
	despair.erase_cell(Vector2i(coord.x -1, coord.y))
	despair.erase_cell(Vector2i(coord.x + 1, coord.y))
	despair.erase_cell(Vector2i(coord.x, coord.y - 1))
	despair.erase_cell(Vector2i(coord.x, coord.y + 1))

# draw top rect line from start_coord to (start_coord.x + next_line.x, start_coord.y)
# draw a right rect line from (start_coord.x + next_line.x, start_coord.y) to (start_coord.x + next_line.x, start_coord.y + next_line.y)
# draw a line from (start_coord.x + next_line.x, start_coord.y + next_line.y) to (start_coord.x, start_coord.y + next_line.y)
# draw a line from (start_coord.x + next_line.x, start_coord.y + next_line.y) to start_coord
# dumb naming clarification: next_line is the length and height of the current rectangle to draw, no idea why I came up with this dumb ass name
func _draw_despair_line(line_start:Vector2i, line_end:Vector2i) -> void:
	#figure out how long a line to draw and in what direction
	var tiles_to_draw = line_end - line_start # the value that is not 0 is which axis to draw on
	var direction: int
	var axis: String
	var count: int
	
	if tiles_to_draw.x != 0:
		direction = sign(line_end.x - line_start.x)
		count = tiles_to_draw.x
		axis = "x"
	else:
		direction = sign(line_end.y - line_start.y)
		count = tiles_to_draw.y
		axis = "y"
	
	var this_is_top = axis == "x" and direction == 1
	var this_is_right = axis == "y" and direction == 1
	var this_is_bottom = axis == "x" and direction == -1
	var this_is_left = axis == "y" and direction == -1
	
	if this_is_bottom:
		print("line_start: %s" % line_start)
		print("line_end: %s" % line_end)
	
	for i in range(0, count, direction):
		var tile_drawn := false
		if despair_rects_drawn > 2:
			# check all the tiles around and fill in blank tile instead
			if this_is_top:
				#this is the top line of the rectangle
				#print("Checking top of rectangle to heal")
				if i == 0:
					#print("Checking top left corner")
					# this is the top, left corner
					for r in range(despair_rects_drawn, 0, -1):
						#print("checking r: %s" % r)
						# check prev tiles to the left, top, and the top left diagonal
						if tile_drawn:
							break
							
						var prev_left = Vector2i(line_start.x - r, line_start.y)
						var prev_top_left = Vector2i(line_start.x - r, line_start.y - r)
						var prev_top = Vector2i(line_start.x, line_start.y - r)
						if used_cells.find(prev_left) == -1:
							#print("top left corner prev_left missing: tile(%s)" % prev_left)
							tile_drawn = true
							despair.set_cell(prev_left, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_top_left) == -1:
							#print("top left corner prev_top_left missing: tile(%s)" % prev_top_left)
							tile_drawn = true
							despair.set_cell(prev_top_left, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_top) == -1:
							#print("top left corner prev_top missing: tile(%s)" % prev_top)
							tile_drawn = true
							despair.set_cell(prev_top, despair_source_id, despair_atlas_coord)
					#print("after checking top left corner tile_drawn is %s" % tile_drawn)
				elif line_start.x + i == line_end.x:
					# this is the top right corner
					#print("Checking top right corner")
					for r in range(despair_rects_drawn, 0, -1):
						# check prev tiles to the right, top, and the top right diagonal
						if tile_drawn:
							break
						
						var prev_right = Vector2i(line_end.x + r, line_end.y)
						var prev_top_right = Vector2i(line_end.x + r, line_end.y - r)
						var prev_top = Vector2i(line_end.x, line_end.y - r)
						if used_cells.find(prev_right) == -1:
							tile_drawn = true
							despair.set_cell(prev_right, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_top_right) == -1:
							tile_drawn = true
							despair.set_cell(prev_top_right, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_top) == -1:
							tile_drawn = true
							despair.set_cell(prev_top, despair_source_id, despair_atlas_coord)
					#print("after checking top right corner tile_drawn is %s" % tile_drawn)
				else:
					# this is just a tile along the top line
					#print("Checking tile along top line")
					for r in range(despair_rects_drawn, 0, -1):
						# check prev tiles to the top
						if tile_drawn:
							break 
							
						var prev_top = Vector2i((line_start.x + i), line_start.y - r)
						if used_cells.find(prev_top) == -1:
							tile_drawn = true
							despair.set_cell(prev_top, despair_source_id, despair_atlas_coord)
					#print("after checking top tile tile_drawn is %s" % tile_drawn)
			elif this_is_bottom:
				#this is the bottom line of the rectangle
				if line_start.x + i == line_end.x:
					#print("checking bottom left corner")
					# this is the bottom, left corner
					for r in range(despair_rects_drawn, 0, -1):
						# check prev tiles to the left, bottom, and the bottom left diagonal
						if tile_drawn:
							break
							
						var prev_left = Vector2i(line_start.x - r, line_start.y)
						var prev_bottom_left = Vector2i(line_start.x - r, line_start.y + r)
						var prev_bottom = Vector2i(line_start.x, line_start.y + r)
						if used_cells.find(prev_left) == -1:
							#print("bottom left prev_left healed")
							tile_drawn = true
							despair.set_cell(prev_left, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_bottom_left) == -1:
							#print("bottom left prev_bottom_left healed")
							tile_drawn = true
							despair.set_cell(prev_bottom_left, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_bottom) == -1:
							#print("bottom left prev_bottom healed")
							tile_drawn = true
							despair.set_cell(prev_bottom, despair_source_id, despair_atlas_coord)
				elif i == 0:
					# this is the bottom right corner
					#print("checking bottom right corner")
					for r in range(despair_rects_drawn, 0, -1):
						# check prev tiles to the right, bottom, and the bottom right diagonal
						
						if tile_drawn:
							break
							
						#print("checking r: %s" % r)
						var prev_right = Vector2i(line_start.x + r, line_start.y)
						var prev_bottom_right = Vector2i(line_start.x + r, line_start.y + r)
						var prev_bottom = Vector2i(line_start.x, line_start.y + r)
						if used_cells.find(prev_right) == -1:
							#print("bottom right prev_right healed tile at (%s)" % prev_right)
							tile_drawn = true
							despair.set_cell(prev_right, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_bottom_right) == -1:
							#print("bottom right prev_bottom_right healed")
							tile_drawn = true
							despair.set_cell(prev_bottom_right, despair_source_id, despair_atlas_coord)
						if used_cells.find(prev_bottom) == -1:
							#print("bottom right prev_bottom healed")
							tile_drawn = true
							despair.set_cell(prev_bottom, despair_source_id, despair_atlas_coord)
				else:
					# this is just a tile along the bottom line
					for r in range(despair_rects_drawn, 0, -1):
						# check prev tiles to the bottom
						if tile_drawn:
							break 
							
						var prev_bottom = Vector2i((line_start.x + i), line_start.y + r)
						if used_cells.find(prev_bottom) == -1:
							tile_drawn = true
							despair.set_cell(prev_bottom, despair_source_id, despair_atlas_coord)
			elif this_is_right:
				# this is just a tile along the right side
				for r in range(despair_rects_drawn, 0, -1):
					# check prev tiles to the right
					if tile_drawn:
						break 
						
					var prev_right = Vector2i(line_end.x + r, line_start.y + i)
					if used_cells.find(prev_right) == -1:
						tile_drawn = true
						despair.set_cell(prev_right, despair_source_id, despair_atlas_coord)
			else:
				# this is just a tile along the left side
				#print("checking left side for healing")
				for r in range(despair_rects_drawn, 0, -1):
					# check prev tiles to the right
					if tile_drawn:
						break 
					#print("r is %s" % r)
					var prev_left = Vector2i(line_start.x - r, line_start.y + i)
					if used_cells.find(prev_left) == -1:
						#print("Healing prev_left tile at %s" % prev_left)
						tile_drawn = true
						despair.set_cell(prev_left, despair_source_id, despair_atlas_coord)
		if not tile_drawn:
			if axis == "x":
				despair.set_cell(Vector2i(line_start.x + i, line_start.y), despair_source_id, despair_atlas_coord)
			else:
				despair.set_cell(Vector2i(line_start.x, line_start.y + i), despair_source_id, despair_atlas_coord)


func _on_retry_button_pressed() -> void:
	var next_level = "Lyric%s" % scene_number
	SceneManager.swap_scenes(SceneRegistry.levels[next_level], get_tree().root, self, "fade_to_black")


func _on_quit_button_pressed() -> void:
	SceneManager.swap_scenes(SceneRegistry.menus["StartScreen"], get_tree().root, self, "fade_to_black")
