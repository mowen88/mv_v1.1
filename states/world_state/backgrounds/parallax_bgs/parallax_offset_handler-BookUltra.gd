extends Node2D

@export_range(0.0, 1.0, 0.01) var parallax_factor: float = 0.5

var reference_camera_position: Vector2
var reference_position: Vector2

@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _ready() -> void:
	reference_camera_position = camera.get_screen_center_position()
	reference_position = global_position

func _process(_delta: float) -> void:
	if not is_instance_valid(camera):
		return

	var camera_position := camera.get_screen_center_position()
	var camera_delta := camera_position - reference_camera_position

	global_position = reference_position + camera_delta * parallax_factor

func reset_reference() -> void:
	reference_camera_position = camera.get_screen_center_position()
	reference_position = global_position
