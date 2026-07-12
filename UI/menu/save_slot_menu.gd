extends VBoxContainer

signal back_requested
signal slot_requested(slot_id: String)
signal delete_requested(slot_id: String) # New signal for deletion

func _ready() -> void:
	# 1. Wire up standard slot selections (looking inside the rows)
	$SlotRow1/SlotButton1.pressed.connect(func(): slot_requested.emit("1"))
	$SlotRow2/SlotButton2.pressed.connect(func(): slot_requested.emit("2"))
	$SlotRow3/SlotButton3.pressed.connect(func(): slot_requested.emit("3"))
	
	# 2. Wire up your delete button selections
	$SlotRow1/DeleteButton1.pressed.connect(func(): delete_requested.emit("1"))
	$SlotRow2/DeleteButton2.pressed.connect(func(): delete_requested.emit("2"))
	$SlotRow3/DeleteButton3.pressed.connect(func(): delete_requested.emit("3"))
	
	# 3. Wire up back navigation (still a direct child of VBoxContainer)
	$BackButton.pressed.connect(func(): back_requested.emit())
	
	# Clean up focus modes safely across all nested buttons
	for row in [$SlotRow1, $SlotRow2, $SlotRow3]:
		for button in row.get_children():
			if button is Control:
				button.focus_mode = Control.FOCUS_NONE
	$BackButton.focus_mode = Control.FOCUS_NONE
