extends State
class_name PlayerStarJump

@export var deceleration: float
@export var launch_particle: String
@export var launch_sound: AudioStream

var cancel_jump: bool = false

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("jump")
	owner.velocity.y = owner.STAR_JUMP_VELOCITY
	owner.star_jump_particles.emitting = true
	ParticleManager.play(launch_particle, owner.global_position + Vector2(0,8))
	AudioManager.play_sfx(launch_sound, 1, 0.2)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		owner.star_jump_particles.emitting = false
		cancel_jump = true

	if event.is_action_pressed("attack"):
		# Ground slam if holding down
		if Input.is_action_pressed("down") \
		and owner.check_ability("Ground Slam"):
			owner.star_jump_particles.emitting = false
			fsm.change_state("Dive")
			
		elif owner.air_attack_count < 1:# and owner.get_node("AttackTimer").is_stopped():
			owner.star_jump_particles.emitting = false
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
		owner.star_jump_particles.emitting = false
		fsm.change_state("Fall")
