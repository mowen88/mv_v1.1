extends Area2D
class_name RoomExits

func _ready() -> void:
	# Because this script lives directly on the Area2D in the base room, 
	# it automatically connects to its own signal when the room loads
	body_shape_entered.connect(_on_body_shape_entered)

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	# Check body collided is the player
	if body.name != "Player":
		return
		
	# Look up the exact collision shape node using the index provided by the engine
	var hit_collider = get_child(local_shape_index) as CollisionShape2D
	if not hit_collider:
		return
		
	# Extract the exit ID from collision shape name
	var exit_id: int = int(hit_collider.name)
	
	# Handle if player is moving up so we can 
	var top_of_collider: float = hit_collider.global_position.y - hit_collider.shape.size.y / 2
	var above_collider: float = body.global_position.y - top_of_collider
	
	# Get current direction logic to continue through exit in correct direction
	if above_collider < 0:
		body.move_component.direction = 0
	else:
		var true_travel_dir: int = int(sign(body.velocity.x))
		
		if true_travel_dir == 0:
			true_travel_dir = body.move_component.facing
			
		# Lock the direction and facing tracking to the true direction of travel
		body.move_component.direction = true_travel_dir
		body.move_component.facing = true_travel_dir

	# Change the FSM state
	if body.velocity.y < 0:
		body.fsm.change_state("PlayerJump")
	
			
	# Tell the WorldState (via SignalBus) to swap the scenes
	SignalBus.room_change_requested.emit(exit_id)
