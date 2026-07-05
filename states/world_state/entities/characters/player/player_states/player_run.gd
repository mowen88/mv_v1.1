extends State
class_name PlayerRun

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("run")
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		fsm.change_state("PlayerJump")
	
	if event.is_action_pressed("attack") and actor.get_node("AttackTimer").is_stopped():
		fsm.change_state("PlayerAttack")
	
func physics_update(_delta: float) -> void:

	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_component.process_movement(_delta)
	actor.move_and_slide()
	
	if actor.move_component.direction == 0:
		fsm.change_state("PlayerIdle")
	
	# Fall if not on floor
	if not actor.is_on_floor():
		fsm.change_state("PlayerFall")

		
	
	
