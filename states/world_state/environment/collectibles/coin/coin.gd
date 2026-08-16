extends RigidBody2D

@export var collect_particle: String

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collection_area: Area2D = $Area2D
@onready var area_shape: CollisionShape2D = $Area2D/CollisionShape2D

var is_collected: bool = false

func _ready() -> void:
	# 1. Pick a random frame from your sprite sheet
	var total_frames = sprite.hframes * sprite.vframes
	if total_frames > 0:
		sprite.frame = randi() % total_frames
		
	# 2. Keep the collection area disabled initially so it can't be grabbed during the burst
	area_shape.set_deferred("disabled", true)
	
	# Connect the Area2D's overlap signal
	collection_area.body_entered.connect(_on_body_entered)
	
	# 3. Wait for a small time for scatter phase before collection allowed
	await get_tree().create_timer(0.2).timeout
	
	if is_collected or not is_inside_tree():
		return
		
	# 4. Enable the collection area so the player can pick it up
	area_shape.set_deferred("disabled", false)

func _on_body_entered(body: Node) -> void:
	if is_collected:
		return
		
	# Check if the overlapping body is your player
	if body.is_in_group("player"):
		is_collected = true
		body.collect_coin(1)
		ParticleManager.play(collect_particle, global_position)
		queue_free()
