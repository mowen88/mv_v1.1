extends Area2D

@export var lock_x: bool = true
@export var lock_y: bool = true

# Area that triggers the camera ovveride
@onready var activation_area: CollisionShape2D = $CollisionShape2D
# The point the camera will go to
@onready var camera_target: Marker2D = $Marker2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Passing through a bool for lock x and y here when player hits the collider to activate the camera override
	if body.is_in_group("player"):
		SignalBus.camera_override_requested.emit(camera_target.global_position, lock_x, lock_y)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.camera_override_cleared.emit()
