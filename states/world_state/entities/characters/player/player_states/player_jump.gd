extends State
class_name PlayerJump

var gravity: float

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("jump")
	
	owner.jump_counter += 1 # Increments for the double jump
	owner.velocity.y = owner.move_component.jump_velocity
	
	if not Input.is_action_pressed("jump"):
		gravity = owner.move_component.gravity * 4
	else:
		gravity = owner.move_component.gravity

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		gravity = owner.move_component.gravity * 4
		
	if event.is_action_pressed("attack") and owner.get_node("AttackTimer").is_stopped():
		fsm.change_state("AirAttack")

	if event.is_action_pressed("shoot") and\
		owner.energy_component.current_energy == owner.energy_component.max_energy:
			fsm.change_state("BeamBuildUp")
	
func physics_update(_delta: float) -> void:

	# Add gravity
	owner.velocity.y = min(owner.velocity.y + gravity * _delta,\
	owner.move_component.max_fall_speed)
	
	# Handle horizontal movement
	owner.x_input(_delta)
	owner.move_component.process_movement(_delta)
	owner.move_and_slide()
	
	if owner.velocity.y >= 0:
		fsm.change_state("Fall")
