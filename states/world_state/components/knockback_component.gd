class_name KnockbackComponent
extends Node

@export var actor: CharacterBody2D
@export var hurtbox_component: HurtboxComponent
@export var hit_state: State
@export var knockback_resistance: float = 1.0

func _ready() -> void:
	if hurtbox_component:
		# Connect to a wrapper function to handle the signal arguments
		hurtbox_component.hit_received.connect(_apply_force)
	
func _apply_force(attacker_pos: Vector2, force: float) -> void:
	if not actor:
		return
	
	# Physics Logic
	var dir = sign(actor.global_position.x - attacker_pos.x)
	actor.velocity.x = (dir * force) / knockback_resistance
	actor.velocity.y = -100
	
	# State Logic - only happens if FSM exists
	var fsm = actor.get_node_or_null("FiniteStateMachine")
	if fsm and hit_state:
		fsm.change_state(hit_state.name)
