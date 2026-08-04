extends Area2D
class_name DoorExits

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(player: Node2D) -> void:
	if player.is_in_group("player"):
		SignalBus.show_interaction_prompt.emit()

func _on_body_exited(player: Node2D) -> void:
	if player.is_in_group("player"):
		SignalBus.hide_interaction_prompt.emit()
