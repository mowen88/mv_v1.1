extends State

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	
	# Get variable timer and switch state when complete
	var timer = actor.get_tree().create_timer(1)
	timer.timeout.connect(actor.queue_free)

# Inside walker_patrol.gd (An enemy AI state)
func physics_update(delta: float) -> void:
	actor.velocity.y += actor.move_component.gravity * delta
	actor.velocity.x = move_toward(actor.velocity.x, 0, 100 * delta)
	actor.move_and_slide()
