extends Node2D

@onready var current_room_container: Node2D = $CurrentRoom
@onready var player: CharacterBody2D = $Player
@onready var game_camera: Camera2D = $GameCamera
@onready var camera_target: Node2D = $CameraTarget
@onready var touch_controller: CanvasLayer = $TouchController
@onready var menu_canvas: CanvasLayer = $MenuCanvas
@onready var menu_manager: Control = $MenuCanvas/MenuAnchor/MenuManager
@onready var pause_menu: VBoxContainer = $MenuCanvas/MenuAnchor/MenuManager/PauseMenu

var current_room_node: Node2D = null
var current_zone_name: String = ""
var in_cutscene: bool = false

func _ready():
	# Listen to the global bus for when a room's Area2D triggers a transition
	SignalBus.room_change_requested.connect(_on_room_change_requested)
	SignalBus.save_station_activated.connect(_on_save_station_activated)
	
	# Instantiates the first room
	var saved_room_name: String = SaveManager.get_saved_room()
	var saved_room_path: String = "res://states/world_state/rooms/%s/%s.tscn" % [saved_room_name, saved_room_name]
	_load_room(saved_room_path, 0)
	
	pause_menu.unpause_requested.connect(_toggle_game_pause)

func _process(_delta):
	if not in_cutscene and player:
		camera_target.global_position = player.global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause"):
		_toggle_game_pause()
		
func _toggle_game_pause() -> void:
	get_tree().paused = !get_tree().paused
	touch_controller.visible = !get_tree().paused
	menu_canvas.visible = get_tree().paused
	if get_tree().paused:
		menu_manager._initialize_menu("PauseMenu")

func _on_change_music() -> void:
	var room_name = current_room_node.name
	var zone_data = get_zone_data(room_name)
	var bgm_path = zone_data.get("bgm","")
	var target_track = load(bgm_path) as AudioStream if bgm_path != "" else null
	
	if target_track:
		if AudioManager.music_player.stream != target_track:
			AudioManager.start_music(target_track, 2.0)

func get_zone_data(room_filename:String) -> Dictionary:
	var tokens: PackedStringArray = room_filename.to_lower().split("_")
	
	if tokens.size() > 1:
		var zone_letter: String = tokens[1]
		return MapData.ZONE_REGISTRY.get(zone_letter, {})
	
		print(MapData.ZONE_REGISTRY.get(zone_letter, {}))	
	return {}

func _on_save_station_activated() -> void:
	if current_room_node:
		SaveManager.save_at_station(current_room_node.name)
		print_rich("[color=green]SAVE SYSTEM: Game successfully saved at room: %s[/color]" % current_room_node.name)

func _on_room_change_requested(exit_id: int) -> void:
	if not current_room_node:
		return
		
	var current_room_name = current_room_node.name.to_lower()
	
	if MapData.ROOM_REGISTRY.has(current_room_name):
		var target_room_name: String = MapData.ROOM_REGISTRY[current_room_name][exit_id]
		var target_room_path: String = "res://states/world_state/rooms/%s/%s.tscn" % [target_room_name, target_room_name]
		
		_execute_room_swap(target_room_path, exit_id)
		
func _execute_room_swap(next_room_path, target_spawn_id):
	TransitionManager.transition(func():
		for child in current_room_container.get_children():
			child.queue_free()
		
		_load_room(next_room_path, target_spawn_id),
		0.2, 0.2, "grid", "grid"
	)

func _load_room(room_path: String, spawn_id: int) -> void:
	current_room_node = null
	var next_room_scene = load(room_path)
	
	if next_room_scene:
		current_room_node = next_room_scene.instantiate()
		# Force the node name to match the file name so the MapData dictionary works perfectly
		current_room_node.name = room_path.get_file().get_basename() 
		current_room_container.add_child(current_room_node)
		
		# transitions and music
		var zone_data: Dictionary = get_zone_data(current_room_node.name)
		var target_zone_name: String = zone_data.get("zone_name", "")
		
		# Evaluate Banner Trigger
		if target_zone_name != current_zone_name:
			current_zone_name = target_zone_name
			if current_zone_name != "":
				SignalBus.zone_banner_requested.emit(current_zone_name, true)
		else:
			SignalBus.zone_banner_requested.emit("", false)
			
		# Just tell the manager the new state
		var bgm_path: String = zone_data.get("bgm", "")
		AudioManager.start_music(bgm_path, 2.0)
		# ------------------------------------
		
		# Update rooms visited progress in save file
		SaveManager.register_room_visited(current_room_node.name)

		var spawn_node = current_room_node.get_node_or_null("Spawns/" + str(spawn_id))

		player.global_position = spawn_node.global_position
		camera_target.global_position = player.global_position
		game_camera.global_position = player.global_position
		
		_update_camera_limits(current_room_node)
		game_camera.reset_smoothing()

func _update_camera_limits(room_node):
	var limits = room_node.get_node_or_null("CameraLimits") as ReferenceRect
	if limits:
		game_camera.limit_left = int(limits.global_position.x)
		game_camera.limit_top = int(limits.global_position.y)
		game_camera.limit_right = int(limits.global_position.x + limits.size.x)
		game_camera.limit_bottom = int(limits.global_position.y + limits.size.y)
