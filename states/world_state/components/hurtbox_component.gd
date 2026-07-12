
class_name HurtboxComponent
extends Area2D

signal hit_received(attacker_pos: Vector2, knockback_force:float)

# The Hurtbox just needs to hold a reference to the HealthComponent
@export var health_component: HealthComponent
@export var invincibility_duration: float = 0.75

var is_invincible: bool = false

func receive_damage(amount:int, attacker_pos:Vector2, knockback_force:float) -> bool:
	if is_invincible or health_component.current_health <= 0:
		return false
	
	if health_component:
		health_component.damage(amount)

	
	hit_received.emit(attacker_pos, knockback_force)
	SignalBus.player_energy_gained.emit(get_owner())
	
	start_invincibility()
	return true

func start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false
	
