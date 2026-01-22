extends Node2D

@onready var note := $Note
@onready var timer := $Timer
@onready var despair_detector := $DespairDetector

@export var completion_progress := 0.0
@export var tile_interval := 0.5


var note_processing := true
var note_paused := false
var note_to_render := 0
var render_next := false
var total_tiles := -1

var tile_source_id = 0
var ll_corner_atlas_coord := Vector2i(0,10)
var b_tile_atlas_coord := Vector2i(1,10)
var lr_corner_atlas_coord := Vector2i(2,10)
var l_side_atlas_coord := Vector2i(0,9)
var r_side_atlas_coord := Vector2i(2,9)
var tl_corner_atlas_coord := Vector2i(0,8)
var t_tile_atlas_coord := Vector2i(1,8)
var tr_corner_atlas_coord := Vector2i(2,8)
var fill_tile_atlas_coord := Vector2i(1,9)
var stem_atlas_coord := Vector2i(6,8)

var note_path = [
	{"tile": Vector2i(-4,8), "sprite": ll_corner_atlas_coord},
	{"tile": Vector2i(-3,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(-2,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(-1,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(0,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(1,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(2,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(3,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(4,8), "sprite": b_tile_atlas_coord},
	{"tile": Vector2i(5,8), "sprite": lr_corner_atlas_coord},
	{"tile": Vector2i(5,7), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(4,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-3,7), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-4,7), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-4,6), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-3,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(4,6), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(5,6), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(5,5), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(4,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-3,5), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-4,5), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-4,4), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-3,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(4,4), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(5,4), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(5,3), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(4,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-3,3), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-4,3), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-4,2), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-3,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(4,2), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(5,2), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(5,1), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(4,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-3,1), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-4,1), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-4,0), "sprite": l_side_atlas_coord},
	{"tile": Vector2i(-3,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-2,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(-1,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(0,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(1,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(2,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(3,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(4,0), "sprite": fill_tile_atlas_coord},
	{"tile": Vector2i(5,0), "sprite": r_side_atlas_coord},
	{"tile": Vector2i(5,-1), "sprite": tr_corner_atlas_coord},
	{"tile": Vector2i(4,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(3,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(2,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(1,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(0,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(-1,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(-2,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(-3,-1), "sprite": t_tile_atlas_coord},
	{"tile": Vector2i(-4,-1), "sprite": tl_corner_atlas_coord},
	{"tile": Vector2i(5,-2), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-3), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-4), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-5), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-6), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-7), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-8), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-9), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-10), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-11), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-12), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-13), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-14), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-15), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-16), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-17), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-18), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-19), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-20), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-21), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-22), "sprite": stem_atlas_coord},
	{"tile": Vector2i(5,-23), "sprite": stem_atlas_coord},
]

func start_note() -> void:
	note_processing = true
	timer.start()

func toggle_detector() -> void:
	despair_detector.monitoring = not despair_detector.monitoring

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = tile_interval
	total_tiles = note_path.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if despair_detector.monitoring:
		note_processing = not despair_detector.has_overlapping_bodies()
		if despair_detector.has_overlapping_bodies() and not note_paused:
			print("Despair is overlapping a note!")
			note_processing = false
			note_paused = true
		elif not despair_detector.has_overlapping_bodies() and note_paused:
			note_paused = false
			note_processing = true
		
		if note_processing and render_next:
			note.set_cell(note_path[note_to_render].tile, tile_source_id, note_path[note_to_render].sprite)
			note_to_render += 1
			render_next = false
			completion_progress = float(note_to_render) / total_tiles
			#print("note_to_render: %s" % note_to_render)
			#print("total_tiles: %s" % total_tiles)
			#print("completion_progress: %s" % completion_progress)
			if note_to_render == note_path.size():
				note_processing = false
				timer.stop()



func _on_timer_timeout() -> void:
	if note_to_render < note_path.size():
		render_next = true
