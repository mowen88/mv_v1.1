extends Area2D
class_name Exits

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	# 1. Safety check: We only care if the colliding body is the Player
	# (Assuming your player script has 'class_name Player')
	
	if not body is CharacterBody2D or not "fsm" in body:
		print("Something entered the zone: ", body.name) # Add this
		return
		
	# 2. Look up the exact CollisionShape2D child that was touched
	var hit_collider = get_child(local_shape_index) as CollisionShape2D
	if not hit_collider:
		return
		
	# 3. Extract the exit ID straight from the collision shape name (e.g., "1")
	var exit_id: int = int(hit_collider.name)
	
	# 4. Calculate top-surface geometry using the specific shape data
	var top_of_collider: float = hit_collider.global_position.y - hit_collider.shape.size.y / 2
	var above_collider: float = body.global_position.y - top_of_collider
	
	# 5. Coordinate player state updates
	body.move_component.direction = 0 if above_collider < 0 else body.move_component.facing
	
	if body.velocity.y < 0:
		body.fsm.change_state("PlayerJump")
	else:
		body.fsm.change_state("PlayerTransition")
			
	# 6. Inform WorldState via the side-channel bus to drop the room
	SignalBus.room_change_requested.emit(exit_id)
