extends State

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("on_ladder")
	owner.velocity = Vector2(0,0)

func handle_input(event: InputEvent) -> void:
	
	if owner.move_component.direction != 0:
		if event.is_action_pressed("jump"):
			# Move player away from ladder with an initial impulse
			owner.move_component.facing = int(sign(owner.move_component.direction))
			owner.velocity.x = owner.move_component.facing * 100
			fsm.change_state("Jump")

func physics_update(_delta: float) -> void:
	
	if not owner.is_on_ladder():
		fsm.change_state("Fall")
		return
		
	if owner.is_on_floor():
		fsm.change_state("Idle")
		return
	
	if Input.is_action_pressed("jump"):
		fsm.change_state("Climb")
		return

	owner.velocity.y = move_toward(owner.velocity.y, 100.0, 100.0 * _delta)
	owner.x_input(_delta)
	owner.move_and_slide()
