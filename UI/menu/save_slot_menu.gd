extends VBoxContainer

signal back_requested
signal slot_requested(slot_id: String)

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.pressed.connect(_on_button_pressed.bind(child.name))
			child.focus_mode = Control.FOCUS_NONE

func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"SlotButton1":
			slot_requested.emit("1")
		"SlotButton2":
			slot_requested.emit("2")
		"SlotButton3":
			slot_requested.emit("3")
		"BackButton":
			back_requested.emit()
		
