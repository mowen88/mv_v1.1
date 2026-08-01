extends State

@export var death_particle: String

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	
	# Get variable timer and switch state when complete
	var timer = actor.get_tree().create_timer(1)
	timer.timeout.connect(actor.queue_free)

	ParticleManager.play_sprite(death_particle, actor.global_position)
	actor.set_collision_mask_value(2, false)
	actor.hitbox_component.monitoring = false
	actor.hurtbox_component.monitorable = false

func physics_update(delta: float) -> void:
	# Add gravity
	actor.velocity.y = min(actor.velocity.y + actor.move_component.gravity * delta,\
	actor.move_component.max_fall_speed)
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, 500 * delta)
	actor.move_and_slide()
