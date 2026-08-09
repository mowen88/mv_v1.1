extends Area2D

@export var text:String = ""

@onready var persistence_component: PersistenceComponent = $PersistenceComponent

func _ready() -> void:
	persistence_component.persistent_state_loaded.connect(_on_persistent_state_loaded)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.tutorial_message_requested.emit(text)
	
	persistence_component.add_to_peristent_list()

func _on_persistent_state_loaded(previous_position:Vector2) -> void:
	queue_free()
