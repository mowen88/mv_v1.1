extends State
class_name PlayerStarJump

@export var deceleration: float
@export var launch_particle: String
@export var launch_sound: AudioStream

var gravity: float

func enter() -> void:
	
	owner.get_node("AnimatedSprite2D").play("jump")
	owner.jump_counter += 1
	owner.velocity.y = owner.move_component.jump_velocity
	
	owner.star_jump_particles.emitting = true
	ParticleManager.play(launch_particle, owner.global_position + Vector2(0,8))
	AudioManager.play_sfx(launch_sound, 1, 0.2)
	
	if not Input.is_action_pressed("jump"):
		gravity = owner.move_component.gravity * 4
	else:
		gravity = owner.move_component.gravity

func handle_input(event: InputEvent) -> void:

	if event.is_action_released("jump"):
		gravity = owner.move_component.gravity * 4
		
	if event.is_action_pressed("attack"):
		# Ground slam if holding down
		if Input.is_action_pressed("down") \
		and owner.check_ability("Ground Slam"):
			fsm.change_state("Dive")
			owner.star_jump_particles.emitting = false
			
		elif owner.air_attack_count < 1:# and owner.get_node("AttackTimer").is_stopped():
			fsm.change_state("AirAttack")
			owner.star_jump_particles.emitting = false
	
func physics_update(delta: float) -> void:
		# Add gravity
	owner.velocity.y = min(owner.velocity.y + gravity * delta,\
	owner.move_component.max_fall_speed)
	
	# Handle horizontal movement
	owner.x_input(delta)
	owner.move_component.process_movement(delta)
	owner.move_and_slide()
	
	if owner.velocity.y >= 0:
		fsm.change_state("Fall")
		owner.star_jump_particles.emitting = false
