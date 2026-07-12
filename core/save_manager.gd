extends Node

var current_slot: String = "1"

# Your runtime game memory
var SAVE_DATA: Dictionary = {
	"1": {},
	"2": {},
	"3": {}
}

# Helper to build a clean, dynamic path string for each slot
func _get_save_path(slot_id: String) -> String:
	return "user://save_slot_%s.json" % slot_id


func save_at_station(room_name: String) -> void:
	# 1. Update the in-memory dictionary tracking block (RAM)
	if not SAVE_DATA.has(current_slot):
		SAVE_DATA[current_slot] = {}
		
	SAVE_DATA[current_slot]["player_data"] = {
		"room_id": room_name,
		"health": 5, # Replace with dynamic variables if needed
		"max_health": 5,
		"energy": 5
	}
	
	# 2. Immediately commit the update to the hard drive (Disk)
	save_to_disk()


# --- NEW: WRITE DICTIONARY TO STORAGE ---
func save_to_disk() -> void:
	var path = _get_save_path(current_slot)
	
	# Open the file for writing (this will create it if it doesn't exist)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		# JSON.stringify converts the dictionary into a plain text string.
		# The "\t" adds clean tabs so you can open the file in Notepad to debug it!
		var json_string = JSON.stringify(SAVE_DATA[current_slot], "\t")
		file.store_string(json_string)
		file.close()
		print_rich("[color=green]SAVE SYSTEM: Successfully wrote Slot %s to disk.[/color]" % current_slot)
	else:
		print_rich("[color=red]SAVE ERROR: Failed to open file path for writing: %s[/color]" % path)


# --- NEW: READ STORAGE BACK INTO DICTIONARY ---
func load_from_disk(slot_id: String) -> bool:
	var path = _get_save_path(slot_id)
	
	# Safety Check: If the file doesn't exist, we can't load it (New Game scenario)
	if not FileAccess.file_exists(path):
		print_rich("[color=yellow]SAVE SYSTEM: No save file found for Slot %s on disk.[/color]" % slot_id)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		# Convert the text string back into a real Godot Dictionary
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			SAVE_DATA[slot_id] = parsed_data
			print_rich("[color=green]SAVE SYSTEM: Successfully loaded Slot %s from disk.[/color]" % slot_id)
			return true
			
	return false

# Updated helper helper function for WorldState
func get_saved_room() -> String:
	if SAVE_DATA.has(current_slot) and SAVE_DATA[current_slot].has("player_data"):
		return SAVE_DATA[current_slot]["player_data"]["room_id"]
	return "01_a" # Start fallback room

func delete_slot(slot_id: String) -> void:
	# Revert to an empty dictionary in RAM
	SAVE_DATA[slot_id] = {}
	
	# Safely check and delete the physical file from user:// storage
	var path = _get_save_path(slot_id)
	
	# Use FileAccess to check if the file exists
	if FileAccess.file_exists(path):
		var dir = DirAccess.open("user://")
		if dir:
			# remove() is a DirAccess method, path.get_file() returns just the filename
			var error = dir.remove(path.get_file())
			if error == OK:
				print_rich("[color=red]SAVE SYSTEM: Erased save file for Slot %s from disk.[/color]" % slot_id)
			else:
				print_rich("[color=yellow]SAVE ERROR: Failed to delete. Error code: %s[/color]" % error)
	else:
		print_rich("[color=yellow]SAVE SYSTEM: No file existed to delete for Slot %s.[/color]" % slot_id)
