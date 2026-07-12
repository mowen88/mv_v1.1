extends State

@export var knockback_force: float = 100.00
@export var duration: float = 0.2
var timer: float = 0.0

func enter() -> void:
	timer = duration
	# Play a "hit" animation if you have one
	actor.get_node("AnimatedSprite2D").play("fall")

func physics_update(delta: float) -> void:
	timer -= delta
	actor.velocity.y += actor.move_component.gravity * delta
	actor.move_and_slide()
	
	if timer <= 0:
		fsm.change_state("Fall")
