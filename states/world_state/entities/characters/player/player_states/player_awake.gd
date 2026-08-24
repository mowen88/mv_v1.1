
extends State
class_name PlayerAwake

@export var duration: float = 2.4
var timer: float = 0.0

func enter() -> void:
	timer = 0.0
	owner.get_node("AnimatedSprite2D").play("awake")

func physics_update(delta: float) -> void:
	timer += delta
	if timer >= duration:
		fsm.change_state("Idle")
		
	owner.move_and_slide()


	
	
