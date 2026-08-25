extends Node2D

@export var sound: AudioStream
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox_component = $HitboxComponent

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Start the beam disabled
	disable_beam()

func _on_animation_finished() -> void:
	visible = false
	disable_beam()

func attack(facing_direction: int) -> void:
	# Set the position and flip direction
	position = Vector2(6 * facing_direction, 0)
	scale.x = facing_direction
	# Play sfx
	AudioManager.play_sfx(sound)
	enable_beam()
	animated_sprite.play()

func disable_beam() -> void:
	# Use 'set_deferred' to avoid physics errors
	hitbox_component.monitoring = false
	visible = false

func enable_beam() -> void:
	hitbox_component.monitoring = true
	#hitbox_component.monitorable = true
	visible = true
