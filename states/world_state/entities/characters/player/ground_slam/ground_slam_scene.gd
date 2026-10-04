extends Node2D

signal attack_finished

@export var sound: AudioStream
@onready var animated_sprite = $AnimatedSprite2D
@onready var hitbox_component = $HitboxComponent
@onready var cooldown_timer = $CooldownTimer
@onready var active_timer = $ActiveTimer

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Start the slam disabled
	disable_slam()

func _on_animation_finished() -> void:
	visible = false

func attack() -> void:

	# Play sfx
	AudioManager.play_sfx(sound)
	
	if cooldown_timer.is_stopped():
		#hitbox_component.clear_hitlist()
		cooldown_timer.start()
		active_timer.start()
		enable_slam()
		animated_sprite.play()
		await active_timer.timeout
		disable_slam()
		await cooldown_timer.timeout
		attack_finished.emit()
	
func disable_slam() -> void:
	# Use 'set_deferred' to avoid physics errors
	hitbox_component.monitoring = false
	#hitbox_component.monitorable = false

func enable_slam() -> void:
	hitbox_component.monitoring = true
	#hitbox_component.monitorable = true
	visible = true


	
