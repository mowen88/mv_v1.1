extends State

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	
	# Get variable timer and switch state when complete
	var timer = actor.get_tree().create_timer(randf_range(1.0, 2.0))
	timer.timeout.connect(func(): fsm.change_state("Idle"))
	
# Inside walker_patrol.gd (An enemy AI state)
func physics_update(_delta: float) -> void:
	# Add gravity
	actor.velocity.y += actor.move_component.gravity * _delta
	
	# Turn around if hitting a wall or a ledge
	if actor.is_on_wall():
		actor.move_component.facing *= -1
	
	actor.move_component.direction = actor.move_component.facing
	
	actor.move_component.process_movement(_delta)
	actor.move_and_slide()
