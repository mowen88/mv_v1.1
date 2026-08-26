
extends State
class_name PlayerIdle

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("idle")
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		fsm.change_state("Jump")
	
	if event.is_action_pressed("attack") and owner.get_node("AttackTimer").is_stopped():
		fsm.change_state("Attack")
	
	if event.is_action_pressed("shoot") and\
	owner.energy_component.current_energy == owner.energy_component.max_energy:
		fsm.change_state("BeamBuildUp")
		
func physics_update(_delta: float) -> void:

	# Handle horizontal movement
	owner.x_input(_delta)
	owner.move_component.process_movement(_delta)
	owner.move_and_slide()
	
	# Fall if not on floor
	if not owner.is_on_floor():
		if owner.coyote_timer.is_stopped():
			owner.coyote_timer.start()
		fsm.change_state("Fall")
		return
	
	if owner.move_component.direction != 0:
		fsm.change_state("Run")
		return
