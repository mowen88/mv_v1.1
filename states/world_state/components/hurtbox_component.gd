
class_name HurtboxComponent
extends Area2D

signal hit_received(hitbox: Area2D, knockback_force:float)

@export var particle_name: String
@export var sound: AudioStream
@export var health_component: HealthComponent
@export var invincibility_duration: float = 0.75

var is_invincible: bool = false

func receive_damage(hitbox: Node2D, amount:int, knockback_force:float) -> bool:
	var attacker_pos = hitbox.global_position
	
	if is_invincible or health_component.current_health <= 0:
		return false
	
	if health_component:
		health_component.damage(amount)
		
	AudioManager.play_sfx(sound, global_position, 1, 0.15)
	ParticleManager.play(particle_name, global_position)
	SignalBus.screenshake_requested.emit(2.0, 0.0, 0.2)
	
	hit_received.emit(hitbox, knockback_force)
	
	if owner.is_in_group("energy_gaining"):
		SignalBus.player_energy_gained.emit(owner)
	
	start_invincibility()
	return true

func start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

	
