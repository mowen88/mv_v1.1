extends State
class_name PlayerGlide

@export var glide_gravity: float

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("heal")

func handle_input(event: InputEvent) -> void:

	if event.is_action_released("jump"):
			fsm.change_state("fall")

func physics_update(delta: float) -> void:

	if owner.is_on_floor():
		owner.air_attack_count = 0
		fsm.change_state("Idle")
		return
		
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	glide_gravity)

	# Handle horizontal movement
	owner.x_input(delta)
	owner.move_component.process_movement(delta)
	owner.move_and_slide()
	
	# After move and slide so we get the correct wall normal for is_on_slope
	if owner.move_component.is_on_slope():
		owner.air_attack_count = 0
		fsm.change_state("Slide")
	
