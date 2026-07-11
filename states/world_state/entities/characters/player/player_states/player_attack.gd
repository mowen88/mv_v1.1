extends State

@export var deceleration: float = 300
@export var sword_scene: PackedScene

func enter() -> void:
	# Animate
	actor.get_node("AnimatedSprite2D").play("attack")
	
	actor.sword.attack(actor.move_component.facing)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		fsm.change_state("Jump")
	
func physics_update(_delta: float) -> void:
	# Add gravity
	actor.velocity.y += actor.move_component.gravity * _delta
	
	# Handle horizontal slow down
	actor.velocity.x = move_toward(actor.velocity.x, 0, deceleration * _delta)
	actor.move_and_slide()
	
	if actor.sword.cooldown_timer.is_stopped():
		fsm.change_state("Idle")
