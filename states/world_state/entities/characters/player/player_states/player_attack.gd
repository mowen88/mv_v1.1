extends State

@export var deceleration: float
@export var sword_scene: PackedScene

var go_to_special = true

func enter() -> void:
	# Animate
	owner.get_node("AnimatedSprite2D").play("attack")
	owner.sword.attack(owner.move_component.facing)
	go_to_special = true

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("attack"):
		go_to_special = false
		
	if event.is_action_pressed("jump"):
		fsm.change_state("Jump")
	
func physics_update(_delta: float) -> void:
	# Add gravity
	owner.velocity.y += owner.move_component.gravity * _delta
	
	# Handle horizontal slow down
	owner.velocity.x = move_toward(owner.velocity.x, 0, deceleration * _delta)
	owner.move_and_slide()
	
	if owner.sword.cooldown_timer.is_stopped():
		if go_to_special:
			fsm.change_state("BeamBuildUp")
			return
			
		fsm.change_state("Idle")
