extends State

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("idle")
	
	# Get variable timer and switch state when complete
	#var timer = owner.get_tree().create_timer(randf_range(1.0, 2.0))
	#timer.timeout.connect(func(): fsm.change_state("WalkerWalk"))

# Inside walker_patrol.gd (An enemy AI state)
func physics_update(_delta: float) -> void:
	# Add gravity
	owner.velocity.y += owner.move_component.gravity * _delta
	
	if owner.is_on_wall():
		owner.move_component.facing *= -1
	
	owner.move_component.direction = owner.move_component.facing
	
	owner.move_component.process_movement(_delta)
	owner.move_and_slide()
