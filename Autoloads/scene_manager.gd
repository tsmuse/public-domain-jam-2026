extends Node
## This is a variation on the Bacon and Games Scene Manager
## (https://github.com/baconandgames/godot4-game-template)
## I built this version, which is a copy in a lot of ways (at least at first)
## to better understand how it works so I could continue maintianing and evolving it 
## as my needs grew and evolved

signal load_start(loading_screen) ## Triggered when an asset begins loading
signal scene_added(loaded_scene:Node, loading_screen) ## Triggered right after asset is added to SceneTree but before transition animation finishes
signal load_complete(loaded_scene:Node) ## Triggered when loading has completed

signal _content_finished_loading(content) ## internal - triggered when content is loaded and final data handoff and transition out begins
signal _content_invalid(content_path:String) ## internal - triggered when attempting to load invalid content (e.g. an asset does not exist)
signal _content_failed_to_load(content_path:String) ## internal - triggered when loading has started by fails to complete

var _loading_screen_scene:PackedScene = preload("res://Menus/loading_screen.tscn") ## this is the scene to use as the loading screen. Has two scenes for this. Maybe as a customization?
var _loading_screen:LoadingScreen ## internal - reference to the loading screen instance
var _transition:String ## internal - transition being used for current load
var _content_path:String ## internal - stores the path to the asset SceneManager is trying to load
var _load_progress_timer:Timer ## internal - Timer used to check in on load progress
var _load_scene_into:Node ## internal - Node into which we're loading the new scene. Defaults to get_tree().root if left null
var _scene_to_unload:Node ## internal - Node we're unloading. Passing in null with skip the unload, but this isn't reccomended, could have side effects
var _loading_in_progress:bool = false ## internal - used to block SceneManager from attempting to load two things at the same time


# currently only being used to connect to required, internal signals
func _ready():
	_content_invalid.connect(_on_content_invalid)
	_content_failed_to_load.connect(_on_content_failed_to_load)
	_content_finished_loading.connect(_on_content_finished_loading)

## internal - adds the loading screen. The loading screen is added to the root.
## to make changes to where the loading screen ends up you can listen for the scene_added and load_complete signals
## to do repositioning, change z-order or other changes.
func _add_loading_screen(transition_type:String="fade_to_black"):
	_transition = "no_to_transition" if transition_type == "no_transition" else transition_type
	_loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(_loading_screen)
	_loading_screen.start_transition(_transition)

## This is used to change between two scenes.
## scene_to_load: String - Path to the resource you would like to load
## load_into: Node - The Node you'd like to load the resource into
## scene_to_unload: Node - Scene you're unloading, leave null to skip unloading step though YMMV
## transition_type: String - name of transition to use. These need to be added to the LoadingScreen's animation player
func swap_scenes(scene_to_load:String, load_into:Node = null, scene_to_unload:Node = null, transition_type:String="fade_to_black"):
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	_loading_in_progress = true
	if load_into == null: load_into = get_tree().root
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload
	
	_add_loading_screen(transition_type)
	_load_content(scene_to_load)

## internal - initializes content
func _load_content(content_path:String):
	load_start.emit(_loading_screen)
	
	_content_path = content_path
	var loader := ResourceLoader.load_threaded_request(content_path)
	if not ResourceLoader.exists(content_path) or loader == null:
		_content_invalid.emit(content_path)
		return
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(_monitor_load_status)
	
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()

## internal - polls the loading status
func _monitor_load_status():
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_content_invalid.emit(_content_path)
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if _loading_screen != null:
				_loading_screen.update_bar(load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			_content_failed_to_load.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			_content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())

## internal - fires when content has begun loading but failed to complete
func _on_content_failed_to_load(path:String):
	printerr("Error: Failed to load resource: '%s'" % [path])

## internal - fires when content is invalid
func _on_content_invalid(path:String):
	printerr("Error: Cannot load resource: '%s'" % [path])

## internal - fires when content is finished loading. This is responsible for data transfer, adding 
## the incoming scene, removing the outgoing scene, halting the game until the trnsition out finishes
## and also fires the signals you can listen for to manage the SceneTree as things are added.
## This is useful for initalizing things before the user gains control after a transition as well
## as controlling when the user can resume control
func _on_content_finished_loading(incoming_scene):
	var outgoing_scene = _scene_to_unload
	
	#if outgoing scene has data to pass, pass it
	if outgoing_scene != null:
		if outgoing_scene.has_method("get_data") and incoming_scene.has_method("receive_data"):
			incoming_scene.recive_data(outgoing_scene.get_data())
	
	_load_scene_into.add_child(incoming_scene)
	
	# listen to this if you want to perform tasks on the scene immediately after adding it to the tree
	# e.g. moving the HUD back to the top of the scene stack
	scene_added.emit(incoming_scene, _loading_screen)
	
	if _scene_to_unload != null:
		if _scene_to_unload != get_tree().root:
			_scene_to_unload.queue_free()
	
	# used to do stuff right after the scene has loaded
	# e.g. positioning the player before the player is given control
	if incoming_scene.has_method("init_scene"):
		incoming_scene.init_scene()
	
	if _loading_screen != null:
		_loading_screen.finish_transition()
		await _loading_screen.anim_player.animation_finished
	
	# used to do things after the loading screen is gone
	# e.g. handing control to the player
	if incoming_scene.has_method("start_scene"):
		incoming_scene.start_scene()
	
	# all finished, free up SceneManager to load something else and report load completed
	_loading_in_progress = false
	load_complete.emit(incoming_scene)
