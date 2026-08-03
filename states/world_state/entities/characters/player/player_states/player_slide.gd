extends State


func enter() -> void:

	owner.get_node("AnimatedSprite2D").play("jump")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		owner.velocity.x += owner.move_component.facing * 150
		fsm.change_state("Jump")

func physics_update(delta: float) -> void:
	# Add gravity
	#owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	#owner.move_component.max_fall_speed)
	#owner.move_zcomponent.facing = int(sign(owner.velocity.x))
	
	owner.move_component.facing = int(sign(owner.velocity.x))
	owner.move_and_slide()
	
	if owner.is_on_floor():
		fsm.change_state("Fall")
