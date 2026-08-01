extends State
class_name PlayerTransition

@export var duration: float = 0.15
var timer: float = 0.0

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("run")
	timer = duration
	
func physics_update(delta: float) -> void:
	timer -= delta
	actor.move_and_slide()
	
	if timer <= 0:
		fsm.change_state("Fall")

	


		
	
	
