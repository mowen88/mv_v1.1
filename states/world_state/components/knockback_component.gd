class_name KnockbackComponent
extends Node

# The actor is the character body we want to push
@export var actor: CharacterBody2D
@export var force: float = 200.0

func apply_knockback(attacker_pos: Vector2) -> void:
	if not actor: return
	
	# Calculate direction
	var dir = sign(actor.global_position.x - attacker_pos.x)
	
	# Apply impulse (Directly to the actor's velocity)
	actor.velocity.x = dir * force
	actor.velocity.y = -100 # Vertical bounce
