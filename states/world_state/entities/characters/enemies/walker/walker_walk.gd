extends State

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("idle")

# Inside walker_patrol.gd (An enemy AI state)
func physics_update(_delta: float) -> void:
	# Add gravity
	owner.velocity.y += owner.move_component.gravity * _delta
	
	# Turn around if hitting a wall OR if the floor check raycast detects an edge
	if owner.is_on_floor() and owner.health_component.current_health > 0:
		if owner.is_on_wall() or not owner.floor_check.is_colliding():
			owner.move_component.facing *= -1
			
			owner.floor_check.position.x = abs(owner.floor_check.position.x) * sign(owner.move_component.facing)
		
	owner.move_component.direction = owner.move_component.facing
	
	owner.move_component.process_movement(_delta)
	owner.move_and_slide()
