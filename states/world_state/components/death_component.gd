class_name DeathComponent
extends Node

@export var actor: CharacterBody2D
@export var health_component: HealthComponent
@export var hitbox_component: HitboxComponent
@export var fsm: FiniteStateMachine

func _ready() -> void:
	# Get the health component from the parent
	if health_component:
		health_component.died.connect(_on_death)

func _on_death() -> void:
	# Handle the universal death logic here
	actor.set_collision_mask_value(2, false)
	hitbox_component.monitoring = false
	
	if fsm:
		fsm.change_state("Death")

	
	# You could even handle delayed cleanup here
	await get_tree().create_timer(2.0).timeout
	actor.queue_free()
