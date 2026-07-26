extends State

@export var hurt_duration: float = 0.4
var timer: float = 0.0

func enter() -> void:
	actor.get_node("AnimatedSprite2D").play("jump")
	timer = 0.0
	owner.velocity = Vector2.ZERO

func update(delta: float) -> void:
	timer += delta
	# Keep velocity zero while stunned/hurt
	owner.velocity = Vector2.ZERO
	
	# Once the timer finishes, teleport to the safe position and transition back
	if timer >= hurt_duration:
		owner.global_position = owner.last_safe_position
		fsm.change_state("Idle")
