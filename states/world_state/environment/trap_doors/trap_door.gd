extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var state = "open"

func _ready() -> void:
	SignalBus.trap_doors_unlocked.connect(_on_trap_doors_unlocked)
	collision_shape.set_deferred("disabled", true)
	animated_sprite.visible = false

func _on_trap_doors_unlocked(encounter_id:String) -> void:
	state = "open"
	animated_sprite.play("open")
	animated_sprite.animation_finished.connect(func():queue_free())

	# Change/stop music
	
	# Add encounter to persistent states
	SaveManager.save_persistent_object(encounter_id)

func activate() -> void:
	if state == "close":
		return
	
	state = "close"
	animated_sprite.play("close")
	animated_sprite.visible = true
	# Enable collision
	collision_shape.set_deferred("disabled", false)
	# Change music?
	
