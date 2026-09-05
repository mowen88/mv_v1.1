extends Sprite2D

@export var save_sound: AudioStream

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_component: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction_component.interact.connect(_on_save_station_interacted)

func _on_save_station_interacted(player: CharacterBody2D) -> void:

	animated_sprite.play()
	SignalBus.save_station_activated.emit()
	SignalBus.flash_screen.emit()
	
	AudioManager.play_sfx(save_sound)
	ParticleManager.play("hit_effect", interaction_component.global_position)
	player.flash_component.play_flash()
	player.health_component.heal(player.health_component.max_health)
	#player.health_component.max_health = 10
	SignalBus.tutorial_message_requested.emit("Game Saved")
	
	
