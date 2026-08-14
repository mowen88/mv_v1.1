extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var marker = get_node_or_null("Marker2D")
		SignalBus.player_respawn.emit(marker.global_position)
