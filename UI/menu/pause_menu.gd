extends VBoxContainer

signal quit_requested
signal settings_requested
signal unpause_requested

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child.name))
			child.focus_mode = Control.FOCUS_NONE

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"UnpauseButton":
			unpause_requested.emit()
		"SettingsButton":
			settings_requested.emit()
		"QuitToTitleButton":
			quit_requested.emit()

		
