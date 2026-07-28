extends Area2D

@export var text:String = "Default message"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("collided")

func _on_body_entered(body: Node2D) -> void:
	SignalBus.tutorial_message_requested.emit(text)
