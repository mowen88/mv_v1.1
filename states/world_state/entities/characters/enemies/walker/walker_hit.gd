extends State

@export var knockback_force: float = 100.00
@export var stun_duration: float = 0.2

var timer: float = 0.0

func enter() -> void:
	timer = stun_duration
	# Play a "hit" animation if you have one
	owner.get_node("AnimatedSprite2D").play("idle")

func physics_update(delta: float) -> void:
	# Increment timer
	timer -= delta
	
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	
	owner.move_and_slide()
	
	if timer <= 0:
		fsm.change_state("Hit")
