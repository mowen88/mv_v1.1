extends State

func enter() -> void:
	owner.get_node("AnimatedSprite2D").play("climb")
	
	# Fade the player out
	var tween = create_tween()
	tween.tween_property(owner.animated_sprite, "modulate:a", 0.0, 0.75)
