extends State

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	actor.velocity = Vector2(0,0)

func handle_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("jump"):
		fsm.change_state("Climb")

	if actor.move_component.direction != 0:
		if event.is_action_pressed("jump"):
			fsm.change_state("Jump")

func physics_update(_delta: float) -> void:

	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_and_slide()

	if actor.is_on_floor():
		fsm.change_state("Idle")
