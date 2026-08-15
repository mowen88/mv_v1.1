extends State
class_name PlayerTransition

@export var duration: float = 0.5
var timer: float = 0.0

var move_x: float = 0.0

func enter() -> void:
	owner.animated_sprite.play("run")
	timer = duration

func _set_animation() -> void:
	var animation_state = ""
	
	if owner.velocity.y < 0:
		animation_state = "Jump"
	elif owner.velocity.y > 0:
		animation_state = "Fall"
	else:
		animation_state = "Run"
	
	if owner.animated_sprite.animation != animation_state:
		owner.animated_sprite.play(animation_state)
	
	print(animation_state)
	

func physics_update(delta: float) -> void:

	timer -= delta
	
	owner.velocity.x = owner.move_component.facing * owner.move_component.speed
	owner.move_and_slide()
	
	# Change animation to fall during transition state for aasthetics
	_set_animation()
	
	if timer <= 0:
		if owner.is_on_floor():
			fsm.change_state("Idle")
		else:
			fsm.change_state("Fall")
	

	


		
	
	
