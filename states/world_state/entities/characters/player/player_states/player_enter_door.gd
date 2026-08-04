extends State

@export var duration: float = 0.2
var timer: float = 0.0

func enter() -> void:
	timer = duration
	# Play a "hit" animation if you have one
	owner.get_node("AnimatedSprite2D").play("climb")
	
	# Fade the player out
	var tween = create_tween()
	tween.tween_property(owner.animated_sprite, "modulate:a", 0.0, 0.5)

func physics_update(delta: float) -> void:
	
	
	timer -= delta

	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	owner.move_and_slide()
	
	#if timer <= 0:
		#fsm.change_state("Fall")
