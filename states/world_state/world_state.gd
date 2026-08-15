extends Node2D

@onready var current_room_container: Node2D = $CurrentRoom
@onready var player: CharacterBody2D = $Player
@onready var game_camera: Camera2D = $GameCamera
@onready var touch_controller: CanvasLayer = $TouchController
@onready var menu_canvas: CanvasLayer = $MenuCanvas
@onready var cutscene_canvas: CanvasLayer = $CutsceneOverlay
@onready var gameplay_ui: CanvasLayer = $GameplayUI
@onready var menu_manager: Control = $MenuCanvas/MenuAnchor/MenuManager
@onready var pause_menu: VBoxContainer = $MenuCanvas/MenuAnchor/MenuManager/PauseMenu

var current_room_node: Node2D = null
var current_zone_name: String = ""
var in_cutscene: bool = false

func _ready():
	SignalBus.toggle_gameplay_ui.connect(func(val): gameplay_ui.visible = val)
	SignalBus.toggle_touch_controller.connect(func(val): touch_controller.visible = val)
	
	
	SignalBus.room_change_requested.connect(_on_room_change_requested)
	SignalBus.save_station_activated.connect(_on_save_station_activated)
	SignalBus.hit_stop_requested.connect(_on_hit_stop)
	pause_menu.unpause_requested.connect(_toggle_game_pause)

	# Instantiates the first room
	_load_room(SaveManager.get_saved_room(), 0)


func _process(delta: float) -> void:
	if not player:
		return
		
	if in_cutscene:
		return
		
	game_camera.update_target(player, delta)
		
func _unhandled_input(event: InputEvent) -> void:
	if InputManager.cutscene_lock:
		return
		
	if event.is_action_pressed("toggle_pause"):
		_toggle_game_pause()

	if event.is_action_pressed("ui_cancel"): # Press Escape/Back to clear
		SignalBus.camera_override_cleared.emit()


func _on_hit_stop(duration: float) -> void:
	Engine.time_scale = 0.0 # Freeze everything
	await get_tree().create_timer(duration, true, false, true).timeout # Real-time timer that ignores time_scale
	Engine.time_scale = 1.0 # Resume normal game speed
	
func _toggle_game_pause() -> void:
	get_tree().paused = not get_tree().paused
	touch_controller.visible = not get_tree().paused
	menu_canvas.visible = get_tree().paused
	if get_tree().paused:
		menu_manager._initialize_menu("PauseMenu")

func get_zone_data(room_filename:String) -> Dictionary:
	var tokens: PackedStringArray = room_filename.to_lower().split("_")
	
	if tokens.size() > 1:
		var zone_letter: String = tokens[0]
		return MapData.ZONE_REGISTRY.get(zone_letter, {})

	return {}

func _on_save_station_activated() -> void:
	if current_room_node:
		SaveManager.save_at_station(current_room_node.name)
		print_rich("[color=green]SAVE SYSTEM: Game successfully saved at room: %s[/color]" % current_room_node.name)

func _on_room_change_requested(room_scene:PackedScene, target_spawn_id:int) -> void:
	if not current_room_node:
		return
		
	TransitionManager.transition(func():
		for child in current_room_container.get_children():
			child.queue_free()
		
		_load_room(room_scene, target_spawn_id),
		0.2, 0.2, "grid", "grid"
	)

func _load_room(room_scene: PackedScene, spawn_id: int) -> void:

	# 1. Instantiate the PackedScene once directly into current_room_node
	current_room_node = room_scene.instantiate()
	
	if current_room_node:
		# 2. Get the filename from the PackedScene's resource_path
		var room_path = room_scene.resource_path
		
		# 3. Force the node name to match the file name so the MapData dictionary works perfectly
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
		
		# Set the respawn fallback to the room entry
		SignalBus.player_respawn.emit(spawn_node.global_position)
		game_camera.set_room_limits(current_room_node)
		# Move the player to the new spawn point in new room
		player.global_position = spawn_node.global_position
		# Snap the camera to the player by default
		game_camera.snap_to_target(spawn_node)
