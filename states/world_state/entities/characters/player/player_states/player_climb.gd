extends State

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("climb")
	owner.velocity = Vector2(0,0)

func physics_update(_delta: float) -> void:
	if not owner.is_on_ladder():
		fsm.change_state("Fall")
		return
	
	if owner.is_on_floor():
		fsm.change_state("Idle")
		return
	
	if not Input.is_action_pressed("jump"):
		fsm.change_state("OnLadder")
		return

	owner.velocity.y = move_toward(owner.velocity.y, -80.0, 150.0 * _delta)	
	# Handle horizontal movement
	owner.x_input(_delta)
	owner.move_and_slide()
