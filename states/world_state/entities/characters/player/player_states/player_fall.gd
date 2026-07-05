extends State
class_name PlayerFall


func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("fall")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and actor.get_node("AttackTimer").is_stopped():
		fsm.change_state("PlayerAirAttack")

func physics_update(_delta: float) -> void:
	# Add gravity
	actor.velocity.y += actor.move_component.gravity * _delta

	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_component.process_movement(_delta)
	actor.move_and_slide()
	
	if actor.is_on_floor():
		fsm.change_state("PlayerIdle")
		return
