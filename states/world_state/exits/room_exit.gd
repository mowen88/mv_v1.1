extends Area2D
class_name RoomExits

@export var exit_id: int = 1
@export var exit_up: bool = false
@export var transition_x_speed: float = 45.0
@export var transition_y_speed: float = 240.0
@export_file("*.tscn") var target_room_path: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"):
		return
	
	# Load the PackedScene dynamically when colliding
	var room_scene = load(target_room_path) as PackedScene

	# Get true travel direction from current velocity.
	
	# facing and direction is not reliable as player could be 
	# pressing one way but slowing down and travelling in other direction.
	var true_travel_dir: int = int(sign(player.velocity.x))
	
	# If speed is zero, go in direciton of facing
	if true_travel_dir == 0:
		true_travel_dir = player.move_component.facing
	
	# Update the player's actual facing value
	player.move_component.facing = true_travel_dir
	
	# Set a consistent transition move speed
	player.velocity.x = true_travel_dir * transition_x_speed

	if exit_up:
		# Impulse to push the player up
		player.velocity.y = -transition_y_speed
	
	# Set the player's state and call the new room scene to reposition player
	player.fsm.change_state("Transition")
	SignalBus.room_change_requested.emit(room_scene, exit_id)
