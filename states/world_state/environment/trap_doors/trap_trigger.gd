extends Area2D

@export var persistent_id: String = ""
@onready var door_container: Node2D = $DoorContainer

func _ready() -> void:
	_kill_if_not_persistent()
	body_entered.connect(_on_body_entered)
	
	# Check if should be spawned or not, queue free if not
func _kill_if_not_persistent() -> void:
	if is_in_group("persistent") and persistent_id != "":
			var slot_data = SaveManager.SAVE_DATA.get(SaveManager.current_slot, {})
			var persistent_list = slot_data.get("persistent_objects", [])
			
			if persistent_id in persistent_list:
				queue_free()
	
func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"):
		return
	
	# Loop through all doors in the container and trigger them
	for child in door_container.get_children():
		if child.has_method("activate"):
			child.activate()
				
	set_deferred("monitoring", false)
