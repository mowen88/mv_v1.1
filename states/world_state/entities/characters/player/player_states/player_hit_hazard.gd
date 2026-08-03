extends State

@export var deceleration: float = 1000.0
@export var hurt_duration: float = 0.5

var timer: float = 0.0

func enter() -> void:
	SignalBus.screenshake_requested.emit(5.0, 5.0, 0.2)
	owner.get_node("AnimatedSprite2D").play("jump")
	timer = 0.0

func physics_update(delta: float) -> void:
	timer += delta
	
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()

	# Once the timer finishes, teleport to the safe position and transition back
	if timer >= hurt_duration:
		owner.global_position = owner.last_safe_position
		owner.hurtbox_component.start_invincibility()
		owner.flash_component.play_flash()
		fsm.change_state("Idle")
