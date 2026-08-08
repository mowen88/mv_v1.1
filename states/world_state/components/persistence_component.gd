

class_name PersistenceComponent
extends Node

signal persistent_state_loaded(position:Vector2)

@export var persistent_id: String = ""

func _ready() -> void:
	# Deferred to ensure signals trigger due to child instancing order
	_get_persistent_state.call_deferred()
	
func _get_persistent_state() -> void:
	# Check if been "used" per say in persistent list
	if persistent_id != "":
		var slot_data = SaveManager.SAVE_DATA.get(SaveManager.current_slot, {})
		var persistent_list = slot_data.get("persistent_objects", [])
		
		if persistent_id in persistent_list:
			# Emit signal to notify owner that it must check the persistent state first
			persistent_state_loaded.emit(owner.global_position)

# Add to persistence list
func add_to_peristent_list() -> void:
	if persistent_id != "":
		# Add it to the save slot data
		SaveManager.save_persistent_object(persistent_id)
		# Instantly change the state of the object to its persistent state
		persistent_state_loaded.emit(owner.global_position)
