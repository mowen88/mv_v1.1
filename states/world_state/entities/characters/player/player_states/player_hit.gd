extends State

@export var knockback_force: float = 100.00
@export var duration: float = 0.2
var timer: float = 0.0

func enter() -> void:
	timer = duration

	owner.animated_sprite.play("fall")

func physics_update(delta: float) -> void:
	timer -= delta
	
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	owner.move_and_slide()
	
	if timer <= 0:
		fsm.change_state("Fall")
