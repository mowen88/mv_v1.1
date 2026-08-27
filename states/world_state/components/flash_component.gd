class_name FlashComponent
extends Node

@export var sprite: AnimatedSprite2D 
@export var hurtbox_component: HurtboxComponent
@export var flash_duration: float = 0.05

func _ready() -> void:
	# Connected via hit recieved signal from hurtbox
	if hurtbox_component:
		hurtbox_component.hit_received.connect(play_flash)

func play_flash(hitbox: Area2D = null, _knockback: float = 0.0) -> void:
	# Early return if no sprite, no material
	if not sprite or not sprite.material:
		return

	# Flicker effect logic
	for i in range(2):
		sprite.material.set_shader_parameter("flash_active", true)
		await get_tree().create_timer(flash_duration).timeout
		sprite.material.set_shader_parameter("flash_active", false)
		await get_tree().create_timer(flash_duration).timeout
