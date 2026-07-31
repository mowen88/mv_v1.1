class_name Bush
extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var flash_component: FlashComponent = $FlashComponent

func _ready() -> void:	
	health_component.health_changed.connect(_on_health_reduced)

func _on_health_reduced(current_health: int) -> void:
	# Play your flash feedback
	flash_component.play_flash()
		
	var damage_taken = health_component.max_health - health_component.current_health
	
	# Clamp the frame index so it doesn't exceed your sprite frame count
	var frame_count = animated_sprite.sprite_frames.get_frame_count("default") -1
	animated_sprite.frame = clampi(damage_taken, 0, frame_count)
	
	# If health hits 0, queue_free or trigger destruction particles
	if health_component.current_health <= 0:
		queue_free()
	
