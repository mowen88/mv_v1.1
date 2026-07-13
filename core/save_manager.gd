extends Node

# --- SETTINGS CONFIGURATION ---
const SETTINGS_PATH = "user://settings.json"

var SETTINGS_DATA: Dictionary = {
	"Master Volume": 1.0,
	"Music Volume": 1.0,
	"SFX Volume": 1.0,
	"Battery Saver": true,
	"Screenshake": true,
	"Vibration": true,
}

# --- SAVE SLOT CONFIGURATION ---
var current_slot: String = "1"

# Your runtime game memory
var SAVE_DATA: Dictionary = {
	"1": {},
	"2": {},
	"3": {}
}

func _ready() -> void:
	# Automatically load settings when the game boots
	load_settings()

# --- SETTINGS MANAGEMENT ---

func update_setting(key: String, value) -> void:
	if SETTINGS_DATA.has(key):
		SETTINGS_DATA[key] = value
		save_settings() # Autosave whenever setting changes
	else:
		push_warning("Setting key not found: " + key)

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(SETTINGS_DATA, "\t")
		file.store_string(json_string)
		file.close()
		print_rich("[color=cyan]SAVE SYSTEM: Settings saved to disk.[/color]")

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return # Use defaults if no file exists
		
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			# Merge loaded data into existing dictionary
			for key in parsed_data:
				if SETTINGS_DATA.has(key):
					SETTINGS_DATA[key] = parsed_data[key]
			print_rich("[color=cyan]SAVE SYSTEM: Settings loaded from disk.[/color]")
		file.close()

# --- SAVE SLOT MANAGEMENT ---

# Helper to build a clean, dynamic path string for each slot
func _get_save_path(slot_id: String) -> String:
	return "user://save_slot_%s.json" % slot_id

func save_at_station(room_name: String) -> void:
	# 1. Update the in-memory dictionary tracking block (RAM)
	if not SAVE_DATA.has(current_slot):
		SAVE_DATA[current_slot] = {}
		
	SAVE_DATA[current_slot]["player_data"] = {
		"room_id": room_name,
		"health": 5, 
		"max_health": 5,
		"energy": 5
	}
	
	# 2. Immediately commit the update to the hard drive (Disk)
	save_to_disk()

func save_to_disk() -> void:
	var path = _get_save_path(current_slot)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(SAVE_DATA[current_slot], "\t")
		file.store_string(json_string)
		file.close()
		print_rich("[color=green]SAVE SYSTEM: Successfully wrote Slot %s to disk.[/color]" % current_slot)
	else:
		print_rich("[color=red]SAVE ERROR: Failed to open file path for writing: %s[/color]" % path)

func load_from_disk(slot_id: String) -> bool:
	var path = _get_save_path(slot_id)
	
	if not FileAccess.file_exists(path):
		print_rich("[color=yellow]SAVE SYSTEM: No save file found for Slot %s on disk.[/color]" % slot_id)
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			SAVE_DATA[slot_id] = parsed_data
			print_rich("[color=green]SAVE SYSTEM: Successfully loaded Slot %s from disk.[/color]" % slot_id)
			return true
			
	return false

func get_saved_room() -> String:
	if SAVE_DATA.has(current_slot) and SAVE_DATA[current_slot].has("player_data"):
		return SAVE_DATA[current_slot]["player_data"]["room_id"]
	return "01_a" 

func delete_slot(slot_id: String) -> void:
	SAVE_DATA[slot_id] = {}
	
	var path = _get_save_path(slot_id)
	
	if FileAccess.file_exists(path):
		var dir = DirAccess.open("user://")
		if dir:
			var error = dir.remove(path.get_file())
			if error == OK:
				print_rich("[color=red]SAVE SYSTEM: Erased save file for Slot %s from disk.[/color]" % slot_id)
			else:
				print_rich("[color=yellow]SAVE ERROR: Failed to delete. Error code: %s[/color]" % error)
	else:
		print_rich("[color=yellow]SAVE SYSTEM: No file existed to delete for Slot %s.[/color]" % slot_id)
