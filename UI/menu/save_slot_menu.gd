extends VBoxContainer

signal back_requested
signal slot_requested(slot_id: String)
signal delete_requested(slot_id: String)

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
	
	update_slot_labels()
	
func update_slot_labels() -> void:
	var rows = {
		"1": {"btn": $SlotRow1/SlotButton1, "del": $SlotRow1/DeleteButton1},
		"2": {"btn": $SlotRow2/SlotButton2, "del": $SlotRow2/DeleteButton2},
		"3": {"btn": $SlotRow3/SlotButton3, "del": $SlotRow3/DeleteButton3}
	}
	
	for slot_id in rows:
		var slot_button  = rows[slot_id]["btn"]
		var delete_button = rows[slot_id]["del"]
		
		if SaveManager.load_from_disk(slot_id):
			var string_time = SaveManager.get_game_time_rooms_visited_as_string(slot_id)
			slot_button.text = "Slot %s - %s" % [slot_id, string_time]
			# Show delete only if data exists
			delete_button.visible = true
		else:
			slot_button.text = "Slot %s - Empty Slot" % slot_id
			# Hide delete button if slot is empty
			delete_button.visible = false
