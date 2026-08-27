extends State

@export var heal_particle: String
@export var deceleration: float = 1000.0

@export var heal_complete_sound: AudioStream
@export var build_up_sound: AudioStream
var audio_player = AudioStreamPlayer

@export var duration: float = 1.0
var timer: float = 0.0

var go_to_shoot = false

func enter() -> void:
	# Animate
	owner.animated_sprite.play("heal")
	timer = duration
	owner.heal_particles.restart()
	owner.heal_particles.visible = true
	#owner.sword.attack(owner.move_component.facing)
	_instantiate_build_up_sound()

func _instantiate_build_up_sound()-> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = build_up_sound
	audio_player.pitch_scale = 2.0
	owner.add_child(audio_player)
	audio_player.play()

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("shoot"):
		audio_player.queue_free()
		owner.heal_particles.visible = false
		fsm.change_state("idle")
	
func physics_update(delta: float) -> void:
	
	# Stop motion
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, deceleration * delta)
	owner.move_and_slide()
	
	timer -= delta
	if timer <= 0:
		owner.heal_particles.visible = false
		# Go to heal state?
		SignalBus.flash_screen.emit()
		SignalBus.screenshake_requested.emit(4,4,0.5)
		owner.energy_component.consume_energy(owner.energy_component.max_energy)
		owner.health_component.heal(owner.health_component.max_health)
		ParticleManager.play("hit_effect", owner.global_position)
		AudioManager.play_sfx(heal_complete_sound)
		fsm.change_state("Idle")
