extends Area2D
class_name HitboxComponent

@export var damage_amount: int = 1
@export var knockback: float = 150.0

func _ready() -> void:
	# 1. Connect to area_entered instead of body_entered
	area_entered.connect(_on_area_entered)
	
	# 2. Check for overlaps immediately when enabled
	for area in get_overlapping_areas():
		_handle_hit(area)

func _on_area_entered(area: Area2D) -> void:
	_handle_hit(area)


func _handle_hit(area: Area2D) -> void:
	# 3. Check if the area IS a HurtboxComponent
	if area is HurtboxComponent:

		area.receive_damage(damage_amount, owner.global_position)
		
		#_hit_entities.append(area)
		print("Hit ", area.get_parent().name, " successfully!", "Health: ", area.health_component.current_health)
			#_hit_entities.append(area)
			#
			## 5. Access the health component THROUGH the hurtbox
			#if area.health_component:
				#
				#area.health_component.damage(damage_amount)
				#area.hit_received.emit(owner.global_position)
				#print("Hit ", area.get_parent().name, "! Health: ", area.health_component.current_health)
				#
				#
				
