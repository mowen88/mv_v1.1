extends State

@export var heal_particle: String
@export var deceleration: float = 1000.0
@export var duration: float = 1.0

var timer: float = 0.0
var go_to_special = true

func enter() -> void:
	# Animate
	owner.get_node("AnimatedSprite2D").play("fall")
	timer = duration
	go_to_special = true

	#owner.sword.attack(owner.move_component.facing)

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("shoot"):
		go_to_special = false
	
func physics_update(delta: float) -> void:
	
	# Stop motion
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	timer -= delta
	if timer <= 0:

		owner.energy_component.consume_energy(owner.energy_component.max_energy)
		if go_to_special:
			fsm.change_state("jump")
		else:
			owner.health_component.heal(owner.health_component.max_health)
			ParticleManager.play(heal_particle, owner.global_position)
			fsm.change_state("fall")
