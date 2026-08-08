extends State


func enter() -> void:
	
	owner.get_node("AnimatedSprite2D").play("slide")
	
	# Handle jump buffer and immediately transition to jump WITH a horizontal impulse
	if owner.jump_buffer_timer.time_left > 0:
		_slope_jump()

func _slope_jump() -> void:
	owner.jump_buffer_timer.stop()
	owner.velocity.x += owner.move_component.facing * 120
	fsm.change_state("Jump")

func handle_input(event: InputEvent) -> void:
	# Transition to jump WITH a horizontal impulse
	if event.is_action_pressed("jump"):
		_slope_jump()
	
func physics_update(_delta: float) -> void:
	
	# Get off wall determines not sliding anymore robustly as slope is classed as wall
	if not owner.is_on_wall():
		fsm.change_state("Fall")
		return
	
	# In case still on wall, hitting floor sets to idle
	if owner.is_on_floor():
		fsm.change_state("Idle")
		return

	## Add gravity
	#owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	#owner.move_component.max_fall_speed)
	
	#owner.move_component.facing = int(sign(owner.velocity.x))
	owner.move_and_slide()
	
