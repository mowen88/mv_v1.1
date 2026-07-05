extends Area2D
class_name HurtboxComponent

signal hit_received(attacker_pos: Vector2)

# The Hurtbox just needs to hold a reference to the HealthComponent
@export var health_component: HealthComponent
@export var invincibility_duration: float = 0.75

var is_invincible: bool = false

func receive_damage(amount:int, attacker_pos:Vector2) -> bool:
	if is_invincible:
		return false
	
	if health_component:
		health_component.damage(amount)
	
	hit_received.emit(attacker_pos)
	start_invincibility()
	return true

func start_invincibility() -> void:
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false
	
