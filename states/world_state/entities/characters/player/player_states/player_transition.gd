extends State
class_name PlayerTransition

@export var duration: float = 0.15
var timer: float = 0.0

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("run")
	timer = duration
	
func physics_update(delta: float) -> void:
	timer -= delta
	
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	
	owner.move_and_slide()
	
	if timer <= 0:
		fsm.change_state("Fall")

	


		
	
	
