class_name FlashComponent
extends Node

@export var sprite: AnimatedSprite2D 
@export var hurtbox_component: HurtboxComponent
@export var fsm: FiniteStateMachine
@export var flash_duration: float = 0.05

func _ready() -> void:
	if hurtbox_component:
		# Connect to a wrapper function to handle the signal arguments
		hurtbox_component.hit_received.connect(_on_hurtbox_hit)

# This wrapper captures the two arguments emitted by the signal
func _on_hurtbox_hit(_attacker_pos: Vector2, _knockback_force: float) -> void:
		play_flash()

func play_flash() -> void:
	# Stop if no sprite, no material, OR if the current state is "Death"
	if not sprite or not sprite.material:
		return
		
	if fsm and fsm.current_state.name == "Death":
		return
		
	# Flicker effect logic
	for i in range(3):
		sprite.material.set_shader_parameter("flash_active", true)
		await get_tree().create_timer(flash_duration).timeout
		sprite.material.set_shader_parameter("flash_active", false)
		await get_tree().create_timer(flash_duration).timeout
