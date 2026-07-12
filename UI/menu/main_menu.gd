extends VBoxContainer

signal continue_requested
signal settings_requested
signal new_game_requested

func _ready() -> void:
	for child in get_children():
		if child is Button:
			
			child.pressed.connect(_on_button_pressed.bind(child.name))
			child.focus_mode = Control.FOCUS_NONE

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"NewGameButton": 
			new_game_requested.emit()
		"ContinueButton": 
			continue_requested.emit()
		"SettingsButton": 
			settings_requested.emit()
