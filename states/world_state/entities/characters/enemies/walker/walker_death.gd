extends State

@export var particle_scene: PackedScene

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("idle")
	
	# Get variable timer and switch state when complete
	var timer = actor.get_tree().create_timer(1)
	timer.timeout.connect(actor.queue_free)

func physics_update(delta: float) -> void:
	# Add gravity
	actor.velocity.y = min(actor.velocity.y + actor.move_component.gravity * delta,\
	actor.move_component.max_fall_speed)
	
	actor.velocity.x = move_toward(actor.velocity.x, 0, 500 * delta)
	actor.move_and_slide()
