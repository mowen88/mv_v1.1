extends State

@export var death_particle: String
@export var deceleration: float = 1000.0
@export var duration: float = 1.5
var timer: float = 1.5

func enter() -> void:
	ParticleManager.play(death_particle, owner.global_position)
	owner.get_node("AnimatedSprite2D").play("jump")
	timer = 0.0
	
	# Set the player facing
	owner.move_component.facing = -1 if owner.velocity.x > 0 else 1

func physics_update(delta: float) -> void:
	timer += delta
	
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	if timer >= duration:
		StateManager.change_state(StateManager.GameState.WORLD, 0.5, 1.0, "fade", "blinds")
	
