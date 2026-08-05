extends Area2D
class_name RoomExits

@export var exit_id: int = 1
@export var exit_up: bool = false
@export_file("*.tscn") var target_room_path: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"):
		return
	
	# Load the PackedScene dynamically when colliding
	var room_scene = load(target_room_path) as PackedScene

	# Direction and velocity handling
	var true_travel_dir: int = int(sign(player.velocity.x))
	if true_travel_dir == 0:
		true_travel_dir = player.move_component.facing
		
	player.move_component.direction = true_travel_dir
	player.move_component.facing = true_travel_dir

	if exit_up:
		player.velocity.y = -player.move_component.jump_velocity
	
	player.fsm.change_state("Transition")
	
	SignalBus.room_change_requested.emit(room_scene, exit_id)
