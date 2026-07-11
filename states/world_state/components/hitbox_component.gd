extends Area2D
class_name HitboxComponent

signal hit_landed(target: HurtboxComponent)

@export var damage_amount: int = 1
@export var knockback_force: float = 200.0

func _physics_process(_delta: float) -> void:
	# Only check if this area is monitoring collisions
	if not monitoring:
		return
	# Continuously check overlapping areas every physics frame	
	for area in get_overlapping_areas():
		if area is HurtboxComponent:
			area.receive_damage(damage_amount, global_position, knockback_force)
			hit_landed.emit(area)
			print("Hit ", area.get_parent().name, " successfully!", "Health: ", area.health_component.current_health)
