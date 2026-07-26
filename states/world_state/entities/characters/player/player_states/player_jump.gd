extends State
class_name PlayerJump

var gravity: float

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("jump")
	
	actor.jump_counter += 1 # Increments for the double jump
	actor.velocity.y = actor.move_component.jump_velocity
	
	if not Input.is_action_pressed("jump"):
		gravity = actor.move_component.gravity * 4
	else:
		gravity = actor.move_component.gravity

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		gravity = actor.move_component.gravity * 4
		
	if event.is_action_pressed("attack") and actor.get_node("AttackTimer").is_stopped():
		fsm.change_state("AirAttack")

	if event.is_action_pressed("shoot") and\
		actor.energy_component.current_energy == actor.energy_component.max_energy:
			fsm.change_state("Heal")
	
func physics_update(_delta: float) -> void:

	# Add gravity
	actor.velocity.y = min(actor.velocity.y + gravity * _delta,\
	actor.move_component.max_fall_speed)
	
	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_component.process_movement(_delta)
	actor.move_and_slide()
	
	if actor.velocity.y >= 0:
		fsm.change_state("Fall")
