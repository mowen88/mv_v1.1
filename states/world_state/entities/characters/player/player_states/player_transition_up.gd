extends State
class_name PlayerTransitionUp

@export var duration: float = 0.5
var timer: float = 0.0

func enter() -> void:
	owner.animated_sprite.play("jump")
	timer = duration
	
func physics_update(delta: float) -> void:
	timer -= delta
	
	owner.velocity.y = -60
	owner.move_and_slide()

	if timer <= 0:
		if owner.is_on_floor():
			fsm.change_state("Idle")
		else:
			fsm.change_state("Fall")
	


		
	
	
