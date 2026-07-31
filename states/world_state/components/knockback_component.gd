class_name KnockbackComponent
extends Node

@export var actor: CharacterBody2D
@export var fsm: FiniteStateMachine
@export var hurtbox_component: HurtboxComponent
@export var knockback_resistance: float = 1.0
@export var bounce: float = 120.0

func _ready() -> void:
	if hurtbox_component:
		# Connect to a wrapper function to handle the signal arguments
		hurtbox_component.hit_received.connect(_apply_force)
	
func _apply_force(attacker_pos: Vector2, force: float) -> void:
	# Physics Logic
	var dir = sign(actor.global_position.x - attacker_pos.x)
	actor.velocity.x = (dir * force) / knockback_resistance
	actor.velocity.y = -bounce
	
	# State Logic - only happens if FSM exists
	if fsm:
		fsm.change_state("Hit")
	
