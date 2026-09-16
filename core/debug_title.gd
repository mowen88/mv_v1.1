extends Node

var base_title: String = "My Awesome Game"

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	DisplayServer.window_set_title("%s | FPS: %d" % [base_title, fps])
