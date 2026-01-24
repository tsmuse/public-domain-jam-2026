extends Node2D
class_name Note

@onready var note := $Note
@onready var timer := $Timer
@onready var despair_detector := $DespairDetector

@export var completion_progress := 0.0
@export var tile_interval := 0.5


var note_processing := false
var note_complete := false
var note_to_render := 0
var render_next := false
var total_tiles := -1

var tile_source_id = 1
var fill_tile_atlas_coord := Vector2i(4,0)

var note_path = []

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
	# check if drawing should continue based on if despair is overlapping or not
	if despair_detector.monitoring and not note_complete:
		# note_processing = not despair_detector.has_overlapping_bodies()
		if despair_detector.has_overlapping_bodies() and note_processing:
			print("Despair is overlapping a note!")
			note_processing = false
		elif not despair_detector.has_overlapping_bodies() and not note_processing:
			note_processing = true

	if note_processing and render_next:
		note.set_cell(note_path[note_to_render].tile, tile_source_id, note_path[note_to_render].sprite)
		note_to_render += 1
		render_next = false
		completion_progress = float(note_to_render) / total_tiles
		# print("note_to_render: %s" % note_to_render)
		# print("total_tiles: %s" % total_tiles)
		# print("completion_progress: %s" % completion_progress)
		if note_to_render == note_path.size():
			note_processing = false
			note_complete = true
			timer.stop()
		
		# print("note_processing %s" % note_processing)



func _on_timer_timeout() -> void:
	if note_to_render < note_path.size():
		render_next = true

