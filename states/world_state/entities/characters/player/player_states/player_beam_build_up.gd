extends State
class_name PlayerBeamBuildUp

@export var deceleration: float = 600.0

@export var build_up_sound: AudioStream
@export var cancel_sound: AudioStream

var audio_player = AudioStreamPlayer

@export var duration: float = 1.0
var timer: float = 0.0

var go_to_shoot = false

func enter() -> void:
	# Animate
	owner.animated_sprite.play("beam_build_up")
	timer = duration
	_instantiate_build_up_sound()

func _instantiate_build_up_sound()-> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = build_up_sound
	audio_player.pitch_scale = 2.0
	owner.add_child(audio_player)
	audio_player.play()

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("attack"):
		audio_player.queue_free()
		AudioManager.play_sfx(cancel_sound)
		if owner.is_on_floor():
			fsm.change_state("idle")
		else:
			fsm.change_state("fall")
	
func physics_update(delta: float) -> void:
	
	# Stop motion
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	timer -= delta
	if timer <= 0:
		SignalBus.flash_screen.emit()
		SignalBus.screenshake_requested.emit(24,0,0.5)
		owner.energy_component.consume_energy(owner.energy_component.max_energy)
		owner.beam.attack(owner.move_component.facing)
		fsm.change_state("BeamKnockback")
