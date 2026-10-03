
extends State
class_name PlayerSlam

@export var duration: float
var timer: float = 0.0

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("heal")
	timer = duration
		
func physics_update(delta: float) -> void:

	timer -= delta
	if timer <= 0:
		fsm.change_state("Idle")
		
