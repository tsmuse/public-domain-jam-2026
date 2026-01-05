class_name SaveData
extends JSONLoader

# The default_save_file.json needs to be set up to work with whatever you write here

# example of accepted data values
enum LEVEL_STATUS {
	LOCKED,
	UNLOCKED,
	COMPLETE
}

# example functions
func read_level_progress(level_id: String) -> int:
	assert(!SceneRegistry.levels.has(level_id), "Level with id %s does not exist" % level_id)
	return data.level_progress[level_id]

func update_level_progress(level_id: String, value:int, save_now := true):
	assert(!SceneRegistry.levels.has(level_id), "Level with id %s does not exist" % level_id)
	if !LEVEL_STATUS.has(value):
		push_error("%s is an unrecognized level progress value. Save failed." % value)
		return
	
	data.level_progress[level_id] = value
	if save_now: write_save(data)
