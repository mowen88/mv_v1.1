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
	if flash_component:
		flash_component.play_flash()
		
	# Calculate which frame to show based on damage taken
	# If max health is 3 (Frames 0, 1, 2), map health downward:
	var damage_taken = health_component.max_health - health_component.current_health
	
	# Clamp the frame index so it doesn't exceed your sprite frame count (0 to 2)
	animated_sprite.frame = clampi(damage_taken, 0, animated_sprite.sprite_frames.get_frame_count("default") - 1)
	
	# If health hits 0, queue_free or trigger destruction particles
	if health_component.current_health <= 0:
		queue_free()
	
