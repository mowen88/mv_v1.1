extends State
class_name PlayerDive

@export var dive_sound: AudioStream
@export var dive_speed: float

@export var duration: float
var timer: float = 0.0

func enter() -> void:
	AudioManager.play_sfx(dive_sound)
	# Animate
	owner.animated_sprite.play("heal")
	timer = duration
	owner.velocity = Vector2.ZERO

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		owner.velocity = Vector2.ZERO
		fsm.change_state("fall")
	
func physics_update(delta: float) -> void:
	if owner.is_on_floor():
		fsm.change_state("Slam")
		return
	
	timer -= delta
	if timer <= 0:
		owner.velocity.y = dive_speed

	owner.move_and_slide()
