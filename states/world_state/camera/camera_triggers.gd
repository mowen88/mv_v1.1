extends Area2D

@export var lock_x: bool = true
@export var lock_y: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var rect_center = global_position
		if collision_shape:
			rect_center = collision_shape.global_position

		SignalBus.camera_override_requested.emit(rect_center, lock_x, lock_y)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.camera_override_cleared.emit()
