extends Area2D
class_name RoomExits

@export var exit_id: int = 1
@export var exit_up: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"):
		return
	
	# Use currently velocity to get the direction to move in
	# This is required, as facing and direction can change due to friction
	# and player can go the wrong way back in to previous room!
	var true_travel_dir: int = int(sign(player.velocity.x))
	if true_travel_dir == 0:
		true_travel_dir = player.move_component.facing
		
	# Set the player's move direction
	player.move_component.direction = true_travel_dir
	player.move_component.facing = true_travel_dir

	# Impulse up if player is transitioning up
	if exit_up:
		player.velocity.y = -250
	
	player.fsm.change_state("Transition")
	
	SignalBus.room_change_requested.emit(exit_id)
