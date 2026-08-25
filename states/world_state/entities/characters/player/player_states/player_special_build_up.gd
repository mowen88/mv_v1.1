extends State

@export var heal_particle: String
@export var deceleration: float = 1000.0
@export var duration: float = 1.0

var timer: float = 0.0
var go_to_shoot = false

func enter() -> void:
	# Animate
	owner.animated_sprite.play("beam_build_up")
	timer = duration

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("attack"):
		if owner.is_on_floor():
			fsm.change_state("idle")
		else:
			fsm.change_state("fall")
	
func physics_update(delta: float) -> void:
	
	# Stop motion
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	timer -= delta
	if timer <= 0:
		# Go to heal state?
		SignalBus.flash_screen.emit()
		owner.energy_component.consume_energy(owner.energy_component.max_energy)
		owner.health_component.heal(owner.health_component.max_health)
		ParticleManager.play(heal_particle, owner.global_position)
		owner.beam.attack(owner.move_component.facing)
		if owner.is_on_floor():
			fsm.change_state("idle")
		else:
			fsm.change_state("fall")
