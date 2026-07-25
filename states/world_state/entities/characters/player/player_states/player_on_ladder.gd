extends State

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("on_ladder")
	actor.velocity = Vector2(0,0)

func handle_input(event: InputEvent) -> void:
	
	if actor.move_component.direction != 0:
		if event.is_action_pressed("jump"):
			# Move player away from ladder with an initial impulse
			actor.move_component.facing = int(sign(actor.move_component.direction))
			actor.velocity.x = actor.move_component.facing * 100
			fsm.change_state("Jump")

func physics_update(_delta: float) -> void:
	
	if not actor.is_on_ladder():
		fsm.change_state("Fall")
		return
		
	if actor.is_on_floor():
		fsm.change_state("Idle")
		return
	
	if Input.is_action_pressed("jump"):
		fsm.change_state("Climb")
		return

	actor.velocity.y = move_toward(actor.velocity.y, 100.0, 100.0 * _delta)
	actor.x_input(_delta)
	actor.move_and_slide()
