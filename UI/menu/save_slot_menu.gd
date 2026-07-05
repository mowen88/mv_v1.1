extends VBoxContainer

signal back_requested

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child.name))
			child.focus_mode = Control.FOCUS_NONE

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"SlotButton1":
			back_requested.emit()
		"SlotButton2":
			back_requested.emit()
		"SlotButton3":
			back_requested.emit()
		"BackButton":
			back_requested.emit()
		
