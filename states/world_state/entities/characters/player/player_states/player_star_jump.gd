extends State
class_name PlayerStarJump

@export var deceleration: float
var cancel_jump: bool = false

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("attack")
	owner.velocity.y = owner.STAR_JUMP_VELOCITY

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		cancel_jump = true

	if event.is_action_pressed("attack"):
		# Ground slam if holding down
		if Input.is_action_pressed("down") \
		and owner.check_ability("Ground Slam"):
			fsm.change_state("Dive")
			
		elif owner.air_attack_count < 1:# and owner.get_node("AttackTimer").is_stopped():
			fsm.change_state("AirAttack")
	
func physics_update(delta: float) -> void:

	# Add gravity
	if not cancel_jump:	
		owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
		owner.move_component.max_fall_speed)
	else:
		owner.velocity.y = move_toward(owner.velocity.y, 0.0, deceleration * delta)
		
	# Handle horizontal movement
	owner.x_input(delta)
	owner.move_component.process_movement(delta)
	owner.move_and_slide()
	
	if owner.velocity.y >= 0:
		cancel_jump = false
		fsm.change_state("Fall")
