extends Node

var input_lock: bool = false

func _input(_event: InputEvent) -> void:
	if input_lock:
		get_viewport().set_input_as_handled()
