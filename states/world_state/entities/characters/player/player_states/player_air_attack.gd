extends State

@export var sword_scene: PackedScene

var go_to_special = true

func enter() -> void:
	# Animate
	owner.get_node("AnimatedSprite2D").play("air_attack")
	owner.sword.attack(owner.move_component.facing)
	go_to_special = true

	owner.get_node("AttackTimer").start()
#func handle_input(event: InputEvent) -> void:
	#if event.is_action_pressed("PlayerJump"):
		#fsm.change_state("PlayerJump")

func handle_input(event:InputEvent) -> void:
	if event.is_action_released("attack"):
		go_to_special = false
		
	if event.is_action_pressed("jump"):
		owner.jump_buffer_timer.start()
	#
func physics_update(_delta: float) -> void:
	if owner.is_on_floor():
		fsm.change_state("Idle")
		
	
	# Add gravity
	owner.velocity.y += owner.move_component.gravity * _delta

	# Handle horizontal movement
	owner.x_input(_delta)
	owner.move_component.process_movement(_delta)
	owner.move_and_slide()
	
	if owner.sword.cooldown_timer.is_stopped():
		if go_to_special:
			fsm.change_state("BeamBuildUp")
			return
			
		fsm.change_state("Fall")

	


			
		
		
