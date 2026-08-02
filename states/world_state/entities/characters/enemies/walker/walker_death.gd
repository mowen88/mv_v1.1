extends State

@export var death_particle: String

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	
	# Queue free after set time
	var timer = actor.get_tree().create_timer(1)
	timer.timeout.connect(actor.queue_free)

	# Remove from collisions while death plays out
	actor.set_collision_mask_value(2, false)
	actor.hitbox_component.monitoring = false
	actor.hurtbox_component.monitorable = false
	
	# Play particles
	ParticleManager.play(death_particle, actor.global_position)

func physics_update(delta: float) -> void:
	# Add gravity
	actor.velocity.y = min(actor.velocity.y + actor.move_component.gravity * delta,\
	actor.move_component.max_fall_speed)
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, 500 * delta)
	actor.move_and_slide()
