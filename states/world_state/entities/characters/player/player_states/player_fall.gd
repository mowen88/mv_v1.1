extends State
class_name PlayerFall

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("fall")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		
		# 1. Coyote jump off a ledge
		if not owner.coyote_timer.is_stopped():
			owner.coyote_timer.stop()
			fsm.change_state("Jump")
		
		# 2. Check if we are near the floor and in the jump buffer window
		elif not owner.jump_buffer_shape_cast.is_colliding():
			# No floor nearby, so it's safe to use mid-air abilities
			if owner.jump_counter == 0:
				fsm.change_state("Jump")
			elif owner.check_ability("Star Jump") and owner.jump_counter == 1:
				fsm.change_state("StarJump")
			elif owner.check_ability("Glide"):
				fsm.change_state("Glide")
			else:
				# Fallback if no mid-air abilities are unlocked
				owner.jump_buffer_timer.start()
		else:
			# Floor is detected by the shape cast; buffer the input for landing
			owner.jump_buffer_timer.start()

		
	if event.is_action_pressed("attack"):
		# Ground slam if holding down
		if Input.is_action_pressed("down") \
		and owner.check_ability("Ground Slam"):
			fsm.change_state("Dive")
			
		elif owner.air_attack_count < 1:# and owner.get_node("AttackTimer").is_stopped():
			fsm.change_state("AirAttack")

func physics_update(delta: float) -> void:
	
	if owner.is_on_floor():
		owner.air_attack_count = 0
		owner.jump_counter = 0
		owner.squash_stretch_component.squash_stretch(Vector2(1.25, 0.75), Vector2(0.9, 1.1), 0.12)
		if owner.jump_buffer_timer.time_left > 0:
			owner.jump_buffer_timer.stop()
			fsm.change_state("Jump")
		else:
			fsm.change_state("Idle")

	#if owner.move_component.on_slope():
		#fsm.change_state("Slide")
		
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	
	if owner.is_on_ladder():
		owner.air_attack_count = 0
		owner.jump_counter = 0
		fsm.change_state("OnLadder")

	# Handle horizontal movement
	owner.x_input(delta)
	owner.move_component.process_movement(delta)
	owner.move_and_slide()
	
	# After move and slide so we get the correct wall normal for is_on_slope
	if owner.move_component.is_on_slope():
		owner.air_attack_count = 0
		owner.jump_counter = 0
		fsm.change_state("Slide")
	
