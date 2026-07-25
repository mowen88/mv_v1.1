extends State

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("climb")
	actor.velocity = Vector2(0,0)

func physics_update(_delta: float) -> void:
	if not actor.is_on_ladder():
		fsm.change_state("Fall")
		return
	
	if actor.is_on_floor():
		fsm.change_state("Idle")
		return
	
	if not Input.is_action_pressed("jump"):
		fsm.change_state("OnLadder")
		return

	actor.velocity.y = move_toward(actor.velocity.y, -80.0, 150.0 * _delta)	
	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_and_slide()
