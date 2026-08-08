class_name HealthComponent
extends Node

signal health_changed
signal max_health_changed
signal died

@export var max_health: int = 5:
	set(value):
		max_health = value
		max_health_changed.emit(max_health)

@onready var current_health: int = max_health

func _ready() -> void:
	_action_if_not_persistent()

# Check if should be spawned or not, queue free if not
func _action_if_not_persistent() -> void:
	if owner.is_in_group("persistent"):
		if "persistent_id" in owner and owner.persistent_id != "":
			var slot_data = SaveManager.SAVE_DATA.get(SaveManager.current_slot, {})
			var persistent_list = slot_data.get("persistent_objects", [])
			
			if owner.persistent_id in persistent_list:
				owner.queue_free()

# Add to persistence list when died if required and in "persistence" group
# owner must have a id string export var set and added to persistence group
func _check_for_persistence_on_death() -> void:
	if owner.is_in_group("persistent"):
		if "persistent_id" in owner and owner.persistent_id != "":
				SaveManager.save_persistent_object(owner.persistent_id)

func damage(amount:int) -> void:

	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health)

	if current_health <= 0:
		_check_for_persistence_on_death()
		died.emit()

func heal(amount: int) -> void:
	if current_health >= max_health: return
	
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health)
