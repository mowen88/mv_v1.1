extends State

@export var deceleration: float = 300
#@export var heal_particles: PackedScene
@export var duration: float = 1.0

var timer: float = 0.0
var go_to_special = true

func enter() -> void:
	# Animate
	actor.get_node("AnimatedSprite2D").play("fall")
	timer = duration
	go_to_special = true

	#actor.sword.attack(actor.move_component.facing)

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("shoot"):
		go_to_special = false
	
func physics_update(_delta: float) -> void:
	
	# Stop motion
	actor.velocity.x = move_toward(actor.velocity.x, 0, deceleration * _delta)
	actor.velocity.y = move_toward(actor.velocity.y, 0, deceleration * _delta)
	actor.move_and_slide()
	
	timer -= _delta
	if timer <= 0:
		actor.energy_component.consume_energy(actor.energy_component.max_energy)
		if go_to_special:
			fsm.change_state("jump")
		else:
			actor.health_component.heal(actor.health_component.max_health)
			fsm.change_state("fall")
