extends State

@export var sword_scene: PackedScene
#var sword_scene = preload("res://states/world_state/entities/characters/player/sword/sword_scene.tscn")

func enter() -> void:
	# Animate
	actor.get_node("AnimatedSprite2D").play("air_attack")

	actor.sword.attack(actor.move_component.facing)

	actor.get_node("AttackTimer").start()
#func handle_input(event: InputEvent) -> void:
	#if event.is_action_pressed("PlayerJump"):
		#fsm.change_state("PlayerJump")
	#
func physics_update(_delta: float) -> void:
	# Add gravity
	actor.velocity.y += actor.move_component.gravity * _delta

	# Handle horizontal movement
	actor.x_input(_delta)
	actor.move_component.process_movement(_delta)
	actor.move_and_slide()
	
	if actor.sword.cooldown_timer.is_stopped():
		fsm.change_state("PlayerFall")

			
		
		
