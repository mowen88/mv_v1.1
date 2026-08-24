class_name KnockbackComponent
extends Node

@export var hurtbox_component: HurtboxComponent
@export var knockback_resistance: float = 1.0
@export var bounce: float = 120.0

func _ready() -> void:
	if hurtbox_component:
		# Connect to a wrapper function to handle the signal arguments
		hurtbox_component.hit_received.connect(_apply_force)
	
func _apply_force(hitbox: Area2D, force: float) -> void:

	var attacker_pos = hitbox.global_position
	# Physics Logic
	var dir = sign(owner.global_position.x - attacker_pos.x)
	owner.velocity.x = (dir * force) / knockback_resistance
	owner.velocity.y = -bounce
