extends Sprite2D

@onready var interaction_component: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction_component.interact.connect(_on_save_station_interacted)

func _on_save_station_interacted(player: CharacterBody2D) -> void:
	# Make sure player is on ground and not moving too fast before leaving
	if abs(player.velocity.x) < 10 and player.is_on_floor():
		
		SignalBus.save_station_activated.emit()
		
		ParticleManager.play("hit_effect", interaction_component.global_position)
		player.flash_component.play_flash()
		SignalBus.tutorial_message_requested.emit("Game Saved")
		
		
