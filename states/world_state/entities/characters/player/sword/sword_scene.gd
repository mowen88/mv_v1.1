extends Node2D

signal attack_finished

@export var sound: AudioStream
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox_component = $HitboxComponent
@onready var cooldown_timer = $CooldownTimer
@onready var active_timer = $ActiveTimer

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Start the sword disabled
	disable_sword()

func _on_animation_finished() -> void:
	visible = false

func attack(facing_direction: int) -> void:
	# Set the position and flip direction
	position = Vector2(6 * facing_direction, 0)
	scale.x = facing_direction
	# Play sfx
	AudioManager.play_sfx(sound, global_position, 1, 0.15)
	
	if cooldown_timer.is_stopped():
		#hitbox_component.clear_hitlist()
		cooldown_timer.start()
		active_timer.start()
		enable_sword()
		animated_sprite.play()
		await active_timer.timeout
		disable_sword()
		await cooldown_timer.timeout
		attack_finished.emit()
	
func disable_sword() -> void:
	# Use 'set_deferred' to avoid physics errors
	hitbox_component.monitoring = false
	#hitbox_component.monitorable = false
	visible = false

func enable_sword() -> void:
	hitbox_component.monitoring = true
	#hitbox_component.monitorable = true
	visible = true


	
