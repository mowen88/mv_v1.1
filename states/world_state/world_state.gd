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
var in_cutscene: bool = false

func _ready():
	# Listen to the global bus for when a room's Area2D triggers a transition
	SignalBus.room_change_requested.connect(_on_room_change_requested)
	
	# Instantiates the first room
	_load_room("res://states/world_state/rooms/01_a/01_a.tscn", 0)
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
