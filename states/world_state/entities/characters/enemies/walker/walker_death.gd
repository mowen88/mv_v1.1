extends State

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	
	# Get variable timer and switch state when complete
	var timer = actor.get_tree().create_timer(1)
	timer.timeout.connect(actor.queue_free)

# Inside walker_patrol.gd (An enemy AI state)
func physics_update(_delta: float) -> void:
	var direction = actor.move_component.facing * -1
	actor.velocity.x = move_toward(direction * 50, 0, actor.move_component.deceleration * _delta)
	actor.move_and_slide()
