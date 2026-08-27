extends State

@export var sword_scene: PackedScene
@export var deceleration: float = 600.0

var go_to_special:bool = true

func enter() -> void:
	# Animate
	owner.air_attack_count += 1
	owner.get_node("AnimatedSprite2D").play("air_attack")
	owner.sword.attack(owner.move_component.facing)

	owner.get_node("AttackTimer").start()
	
	go_to_special = true

func handle_input(event:InputEvent) -> void:
	if event.is_action_released("attack"):
		go_to_special = false
		
	if event.is_action_pressed("jump"):
		owner.jump_buffer_timer.start()
	
func physics_update(delta: float) -> void:
	# 1. Handle physics first
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	if owner.is_on_floor():
		owner.air_attack_count = 0

	# Run this if not hit the floor after slash attack
	if owner.sword.cooldown_timer.is_stopped():
		if go_to_special and owner.energy_component.current_energy == owner.energy_component.max_energy:
			fsm.change_state("BeamBuildUp")
			return
		
		if owner.is_on_floor():
			owner.air_attack_count = 0
			fsm.change_state("Idle")
		else:
			fsm.change_state("Fall")

	
		
	


			
		
		
