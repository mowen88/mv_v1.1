
extends State
class_name PlayerBeamKnockback

@export var duration: float = 0.6
@export var knockback_force:float = 100.0
@export var deceleration: float = 200.0
var timer: float = 0.0

func enter() -> void:
	owner.animated_sprite.play("beam_knockback")
	timer = duration
	owner.velocity.x = -owner.move_component.facing * knockback_force
		
func physics_update(delta: float) -> void:
	timer -= delta
	
	owner.move_and_slide()
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	if timer <= 0:
		if owner.is_on_floor():
			fsm.change_state("Idle")
		else:
			fsm.change_state("Fall")
		
