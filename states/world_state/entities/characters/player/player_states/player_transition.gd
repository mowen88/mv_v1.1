extends State
class_name PlayerTransition

@export var duration: float = 0.5
var timer: float = 0.0

var move_x: float = 0.0

func enter() -> void:
	timer = duration

func physics_update(delta: float) -> void:

	timer -= delta
	
	owner.velocity.x = owner.move_component.facing * owner.move_component.speed
	owner.move_and_slide()

	if timer <= 0:
		if owner.is_on_floor():
			fsm.change_state("Idle")
		else:
			fsm.change_state("Fall")
	

	


		
	
	
