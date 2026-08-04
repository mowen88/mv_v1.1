extends State

@export var duration: float = 1.0
var timer: float = 0.0

func enter() -> void:
	# Stay still wilzl exiting
	owner.velocity.x = 0
	
	timer = duration
	owner.get_node("AnimatedSprite2D").play("exit_door")
#
func physics_update(delta: float) -> void:
	# Safely start fade in after room transitioned using input lock flag
	if not InputManager.input_lock:
		var tween = create_tween()
		tween.tween_property(owner.animated_sprite, "modulate:a", 1.0, 0.6)
		
	timer -= delta
	
	if timer <= 0:
		fsm.change_state("Idle")
