extends Sprite2D

@export var fade_duration: float = 0.3
@export var initial_alpa: float = 0.5

func _ready() -> void:
	# Set the initial starting alpha to 0.5
	modulate.a = initial_alpa
	
	# Animate the opacity down to 0, then free the node
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(queue_free)
