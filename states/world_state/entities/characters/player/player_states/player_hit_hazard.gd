extends State

@export var hurt_duration: float = 0.4
var timer: float = 0.0

func enter() -> void:
	timer = 0.0
	owner.velocity = Vector2.ZERO
		
	# 3. Optional: Trigger screenshake or sound
	SignalBus.screenshake_requested.emit(5.0, 5.0, 0.2)

func update(delta: float) -> void:
	timer += delta
	# Keep velocity zero while stunned/hurt
	owner.velocity = Vector2.ZERO
	
	# Once the timer finishes, teleport to the safe position and transition back
	if timer >= hurt_duration:
		owner.global_position = owner.last_safe_position
		fsm.change_state("Idle")
