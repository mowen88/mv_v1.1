class_name FlashComponent
extends Node

@export var sprite: AnimatedSprite2D # Assign your Sprite2D or AnimatedSprite2D here
@export var flash_duration: float = 0.1

func play_flash() -> void:
	# Use 'material' to access the shader parameters
	sprite.material.set_shader_parameter("flash_active", true)
	await get_tree().create_timer(0.3).timeout
	sprite.material.set_shader_parameter("flash_active", false)
