extends State
class_name PlayerFall

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("fall")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and actor.get_node("AttackTimer").is_stopped():
		fsm.change_state("AirAttack")

	if event.is_action_pressed("shoot") and\
		actor.energy_component.current_energy == actor.energy_component.max_energy:
			fsm.change_state("Heal")

func _check_on_ladder():
	for area in actor.hurtbox_component.get_overlapping_areas():
		if area.is_in_group("ladders"):
			# get specific ladder sahpe
			var shape = area.get_node_or_null("CollisionShape2D")
			actor.global_position.x = shape.global_position.x
			return true

func physics_update(_delta: float) -> void:
	# Add gravity
	actor.velocity.y += actor.move_component.gravity * _delta
	
	if _check_on_ladder():
		fsm.change_state("OnLadder")
		return

	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_component.process_movement(_delta)
	actor.move_and_slide()
	
	if actor.is_on_floor():
		fsm.change_state("Idle")
		return
