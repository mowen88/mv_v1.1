extends VBoxContainer

signal continue_requested
signal settings_requested

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child.name))
			child.focus_mode = Control.FOCUS_NONE

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"NewGameButton": 
			StateManager.change_state(StateManager.GameState.WORLD, 0.5, 1.0, "fade", "blinds")
		"ContinueButton": 
			continue_requested.emit()
		"SettingsButton": 
			settings_requested.emit()
