extends Area2D
class_name InteractionComponent

signal interact(player: CharacterBody2D)

@export var prompt_text: String = "Interact here!"
@onready var interact_label: Label = $InteractLabel

var player: CharacterBody2D

func _ready() -> void:
	interact_label.text = prompt_text
	interact_label.visible = false
	interact_label.modulate.a = 0.0
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	SignalBus.swipe_up_detected.connect(_on_swipe_up)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		interact_label.visible = true
		var tween = create_tween()
		tween.tween_property(interact_label, "modulate:a", 1.0, 0.3)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property(interact_label, "modulate:a", 0.0, 0.3)
		await tween.finished
		interact_label.visible = false

func _on_swipe_up() -> void:
	if InputManager.input_lock:
		return
	# Only trigger if the player is in range and the prompt is visible
	if player and interact_label.visible:
		interact.emit(player)
		# Fade out button / prompt
		var tween = create_tween()
		tween.tween_property(interact_label, "modulate:a", 0.0, 0.3)
