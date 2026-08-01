
class_name HurtboxComponent
extends Area2D

signal hit_received(attacker_pos: Vector2, knockback_force:float)

@export var particle_name: String
@export var sound: AudioStream
@export var health_component: HealthComponent
@export var invincibility_duration: float = 0.75

var is_invincible: bool = false

func receive_damage(amount:int, attacker_pos:Vector2, knockback_force:float) -> bool:
	if is_invincible or health_component.current_health <= 0:
		return false
	
	if health_component:
		health_component.damage(amount)
		AudioManager.play_sfx(sound, global_position, 1, 0.15)
		ParticleManager.play(particle_name, global_position)
	
	hit_received.emit(attacker_pos, knockback_force)
	SignalBus.screenshake_requested.emit(2.0, 0.0, 0.2)
	
	if get_owner().is_in_group("energy_gaining"):
		SignalBus.player_energy_gained.emit(get_owner())
	
	start_invincibility()
	return true

func start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

	
