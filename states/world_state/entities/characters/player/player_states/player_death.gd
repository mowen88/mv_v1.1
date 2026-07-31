extends State

@export var deceleration: float = 1000.0
@export var duration: float = 1.5
var timer: float = 1.5

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("jump")
	timer = 0.0

func physics_update(delta: float) -> void:
	timer += delta
	
	actor.velocity = actor.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	actor.move_and_slide()
	
	if timer >= duration:
		StateManager.change_state(StateManager.GameState.WORLD, 0.5, 1.0, "fade", "blinds")
	
