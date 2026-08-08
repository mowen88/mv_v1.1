class_name Chest
extends StaticBody2D

@export var persistent_id: String = ""
@export var currency_value: int = 25
@export var coin_burst_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var flash_component: FlashComponent =  $FlashComponent
@onready var squash_stretch_component: SquashStretchComponent = $SquashStretchComponent
@export var particle_name: String = "small_blast"

func _ready() -> void:
	health_component.health_changed.connect(_on_health_reduced)
	health_component.died.connect(_on_death)

func _on_health_reduced(current_health: int) -> void:
	flash_component.play_flash()
	squash_stretch_component.squash_stretch(Vector2(1.3, 0.7), Vector2(0.8, 1.2), 0.15)
		
	var damage_taken = health_component.max_health - health_component.current_health
	
	# Clamp the frame index so it doesn't exceed your sprite frame count
	var frame_count = animated_sprite.sprite_frames.get_frame_count("default") -1
	animated_sprite.frame = clampi(damage_taken, 0, frame_count)	
	
func _on_death() -> void:
	if owner and owner.is_in_group("persistent"):
		SaveManager.save_destroyed_object(persistent_id)
		
	ParticleManager.play(particle_name, global_position)
	collision_shape.set_deferred("disabled", true)
	
	if coin_burst_scene:
		var burst = coin_burst_scene.instantiate()
		burst.global_position = global_position
		get_tree().current_scene.add_child(burst)
		
	# Kill it
	queue_free()
