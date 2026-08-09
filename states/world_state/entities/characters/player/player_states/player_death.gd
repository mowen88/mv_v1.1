extends State

@export var death_particle: String
@export var deceleration: float = 1000.0
@export var duration: float = 3.5
var timer: float = 1.5

func enter() -> void:
	
	timer = 0.0
	owner.animated_sprite.play("jump")
	# Play death particle
	ParticleManager.play(death_particle, owner.global_position)
	SignalBus.flash_screen.emit()

	# Set the player facing
	owner.move_component.facing = -1 if owner.velocity.x > 0 else 1
	
	await get_tree().create_timer(1.0).timeout
	# Put player on top of death screen effect
	# Signal the death screen animation/fade
	SignalBus.death_screen_fade.emit(Color.WHITE, 2.0)


func physics_update(delta: float) -> void:
	timer += delta
	
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	if timer >= duration:
		StateManager.change_state(StateManager.GameState.WORLD, 0.5, 1.0, "fade", "blinds")
