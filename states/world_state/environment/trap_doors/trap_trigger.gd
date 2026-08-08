extends Area2D

@onready var door_container: Node2D = $DoorContainer
@onready var persistence_component: PersistenceComponent = $PersistenceComponent

func _ready() -> void:
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	body_entered.connect(_on_body_entered)	
	
func _on_body_entered(player: Node2D) -> void:
	if not player.is_in_group("player"):
		return
	
	# Loop through all doors in the container and trigger them
	for child in door_container.get_children():
		if child.has_method("activate"):
			child.activate()
			## Connect the main add to persistent function to child doors and run
			## it when the door calls to signal for this particular persistent id
			child.open_doors.connect(func():persistence_component.add_to_peristent_list())
	set_deferred("monitoring", false)

func _on_persistent_state_loaded(_previous_position:Vector2) -> void:
	queue_free()
