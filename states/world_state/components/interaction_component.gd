extends Area2D
class_name InteractionComponent

signal interact(player: CharacterBody2D)

@export var prompt_text: String = "Interact here!"
@onready var interact_button: Button = $InteractButton

var player: CharacterBody2D

func _ready() -> void:
	interact_button.text = prompt_text
	interact_button.visible = false
	interact_button.modulate.a = 0.0
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interact_button.pressed.connect(_on_button_pressed)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		interact_button.visible = true
		var tween = create_tween()
		tween.tween_property(interact_button, "modulate:a", 1.0, 0.3)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property(interact_button, "modulate:a", 0.0, 0.3)
		await tween.finished
		interact_button.visible = false

func _on_button_pressed() -> void:
	# Emit the signal so the parent entity knows it was triggered
	if player:
		interact.emit(player)
		var tween = create_tween()
		tween.tween_property(interact_button, "modulate:a", 0.0, 0.3)
