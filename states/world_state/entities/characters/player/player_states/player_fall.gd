extends State
class_name PlayerFall

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("fall")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if not owner.coyote_timer.is_stopped():
			owner.coyote_timer.stop()
			fsm.change_state("jump")
		else:
			owner.jump_buffer_timer.start()
		
	if event.is_action_pressed("attack") and owner.get_node("AttackTimer").is_stopped():
		fsm.change_state("AirAttack")

	if event.is_action_pressed("shoot") and\
		owner.energy_component.current_energy == owner.energy_component.max_energy:
			fsm.change_state("Heal")

func physics_update(delta: float) -> void:

	if owner.is_on_floor():
		owner.squash_stretch_component.squash_stretch(Vector2(1.25, 0.75), Vector2(0.9, 1.1), 0.12)
		if owner.jump_buffer_timer.time_left > 0:
			owner.jump_buffer_timer.stop()
			fsm.change_state("Jump")
		else:
			fsm.change_state("Idle")
		return
		
	#if owner.move_component.on_slope():
		#fsm.change_state("Slide")
		
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	
	if owner.is_on_ladder():
		fsm.change_state("OnLadder")

	# Handle horizontal movement
	owner.x_input(delta)
	owner.move_component.process_movement(delta)
	owner.move_and_slide()
	
	# After move and slide so we get the correct wall normal for is_on_slope
	if owner.move_component.is_on_slope():
		fsm.change_state("Slide")
	
