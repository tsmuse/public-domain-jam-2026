class_name JSONLoader
extends Node

# This is based on the Bacon and Games JSON loader util. It's pretty straight forward
# It doesn't support multiple save files, that's probably something I'll need to add eventually
# This is the base class for the game's SaveData, which is where all the custom logic goes

const save_path: String = "user://user_save.json"
# not sure I love saving the defaults to a file, but I guess that makes it easy to maintain?
# it certainly makes the operation more universal, but I'm quesey about FS hits for some reason
const default_save_file: String = "res://Resources/default_save_file.json" 

var data = {}

func write_save(data_to_save):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data_to_save))
	file.close()
	file = null

func read_save() -> Variant:
	var file = FileAccess.open(save_path, FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	data = save_data
	return data

func load_or_create() -> Variant:
	if FileAccess.file_exists(save_path):
		return read_save()
	else:
		var file = FileAccess.open(default_save_file, FileAccess.READ)
		var default_data = JSON.parse_string(file.get_as_text())
		data = default_data
		write_save(default_data)
		return data

func clear_save():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(default_save_file,FileAccess.READ)
		var default_data = JSON.parse_string((file.get_as_text()))
		data = default_data
		write_save(default_data)

func _ready():
	load_or_create()
