extends State

@export var duration: float = 1.0
var timer: float = 0.0

func enter() -> void:
	# Stay still will exiting
	owner.velocity.x = 0
	
	timer = duration
	# Play a "hit" animation if you have one
	owner.get_node("AnimatedSprite2D").play("on_ladder")

	# Fade the player in
	var tween = create_tween()
	tween.tween_property(owner.animated_sprite, "modulate:a", 1.0, 0.75)
	
func physics_update(delta: float) -> void:
	
	timer -= delta
	
	# Add gravity
	owner.velocity.y = min(owner.velocity.y + owner.move_component.gravity * delta,\
	owner.move_component.max_fall_speed)
	owner.move_and_slide()
	
	if timer <= 0:
		fsm.change_state("Idle")
