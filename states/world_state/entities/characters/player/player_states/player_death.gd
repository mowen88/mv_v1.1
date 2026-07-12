extends State

@export var deceleration: float = 300.0

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("jump")
	var timer = actor.get_tree().create_timer(1.5)
	timer.timeout.connect(_on_death)

func _on_death() -> void:
	StateManager.change_state(StateManager.GameState.WORLD, 0.5, 1.0, "fade", "blinds")
	
func physics_update(_delta: float) -> void:

	# Stop motion
	actor.velocity = Vector2(0,0)
	actor.move_and_slide()
