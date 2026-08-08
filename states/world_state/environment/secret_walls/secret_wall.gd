class_name SecretWall
extends StaticBody2D

@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var tile_map_layer: TileMapLayer = $CanvasGroup/TileMapLayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var persistence_component: PersistenceComponent = $PersistenceComponent
@export var particle_name: String = "small_blast"

func _ready() -> void:	
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	hurtbox_component.hit_received.connect(_on_hit_received)
	health_component.died.connect(_on_death)

func _on_hit_received(hitbox:Area2D, _knockback_force:float) -> void:
	
	var direction = sign(global_position.x - hitbox.global_position.x)
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var home_x = position.x
	
	var push_amount = 4.0 * direction
	
	# Nudge away from the hit
	tween.tween_property(self, "position:x", home_x + push_amount, 0.03)
	# Settle back home
	tween.tween_property(self, "position:x", home_x, 0.08)

func _on_persistent_state_loaded(previous_position:Vector2 = global_position) -> void:
	queue_free()

func _on_death() -> void:
	persistence_component.add_to_peristent_list()

	ParticleManager.play(particle_name, global_position)
	_fade_and_destroy()


func _fade_and_destroy() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	
	var tween = create_tween()
	# Tween canvas the tilemap belongs to get inherit the alpha fade
	# as tilemap itself doesnt support modulate alpha channels
	tween.tween_property(canvas_group, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
