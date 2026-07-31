extends Area2D
class_name RoomExits

@export var exit_id: int = 1
@export var vertical_exit: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	var true_travel_dir: int = int(sign(body.velocity.x))
	if true_travel_dir == 0:
		true_travel_dir = body.move_component.facing
		
	body.move_component.direction = true_travel_dir
	body.move_component.facing = true_travel_dir

	if vertical_exit:
		body.fsm.change_state("Jump")
	
	SignalBus.room_change_requested.emit(exit_id)
