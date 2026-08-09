extends Area2D
class_name RoomExits

@export var exit_id: int = 1
@export var exit_up: bool = false
@export var exit_down: bool = false
@export var transition_x_speed: float = 75.0
@export var transition_y_speed: float = 240.0
@export_file("*.tscn") var target_room_path: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"):
		return
	
	# Handle the player depending on direction of room change
	_handle_player_momentum(player)
	_handle_player_state(player)
	
	# Request the room change
	var room_scene = load(target_room_path) as PackedScene
	SignalBus.room_change_requested.emit(room_scene, exit_id)


func _handle_player_momentum(player: Node2D) -> void:
	# Determine true travel direction from velocity, falling back to facing if stationary
	var true_travel_dir: int = int(sign(player.velocity.x))
	if true_travel_dir == 0:
		true_travel_dir = player.move_component.facing
	
	# Update player facing
	player.move_component.facing = true_travel_dir
	
	# No need to "push" or force the player to move in x axis when falling down
	if not exit_down:
		player.velocity.x = true_travel_dir * transition_x_speed

func _handle_player_state(player: Node2D) -> void:
	if exit_down:
		player.fsm.change_state("Fall")
	elif exit_up:
		player.fsm.change_state("TransitionUp")
