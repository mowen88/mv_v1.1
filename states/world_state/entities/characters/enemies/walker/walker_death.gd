extends State

@export var death_particle: String

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("idle")
	
	# Queue free after set time
	var timer = owner.get_tree().create_timer(1)
	timer.timeout.connect(owner.queue_free)

	# Remove from collisions while death plays out
	owner.set_collision_mask_value(2, false)
	owner.hitbox_component.monitoring = false
	owner.hurtbox_component.monitorable = false
	
	# Play particles
	ParticleManager.play(death_particle, owner.global_position)

func physics_update(delta: float) -> void:
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	
	owner.velocity.x = move_toward(owner.velocity.x, 0, 500 * delta)
	owner.move_and_slide()
