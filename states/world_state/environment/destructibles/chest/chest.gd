class_name Chest
extends StaticBody2D

@export var currency_value: int = 25
@export var coin_burst_scene: PackedScene
@export var particle_name: String = "small_blast"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var flash_component: FlashComponent =  $FlashComponent
@onready var squash_stretch_component: SquashStretchComponent = $SquashStretchComponent
@onready var persistence_component: PersistenceComponent = $PersistenceComponent

func _ready() -> void:
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.died.connect(_on_death)
 
func _on_hit_received(_hitbox:Area2D, _knockback_force:float) -> void:
	flash_component.play_flash()
	squash_stretch_component.squash_stretch(Vector2(1.3, 0.7), Vector2(0.8, 1.2), 0.15)
		
	var damage_taken = health_component.max_health - health_component.current_health
	
	# Clamp the frame index so it doesn't exceed your sprite frame count
	var frame_count = animated_sprite.sprite_frames.get_frame_count("default") -1
	animated_sprite.frame = clampi(damage_taken, 0, frame_count)	
	
func _on_death() -> void:
	persistence_component.add_to_peristent_list()

	ParticleManager.play(particle_name, global_position)
	collision_shape.set_deferred("disabled", true)
	
	if coin_burst_scene:
		var burst = coin_burst_scene.instantiate()
		burst.global_position = global_position
		get_tree().current_scene.add_child(burst)
		

func _on_persistent_state_loaded(previous_position:Vector2) -> void:

	global_position = previous_position
	
	collision_shape.set_deferred("disabled", true)
	set_collision_mask_value(1, false)
	hurtbox_component.monitorable = false

	# Assuming frame 1 (or your final frame) is the open chest sprite
	var max_frame = animated_sprite.sprite_frames.get_frame_count("default") - 1
	animated_sprite.frame = max_frame
