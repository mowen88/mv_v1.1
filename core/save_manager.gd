extends Node

# --- SETTINGS CONFIGURATION ---
const SETTINGS_PATH = "user://settings.json"
const TOTAL_ROOMS: float = 4.0

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
var game_timer_active: bool = false
# REMOVED: var percent_complete: float = 0.0 (Now completely managed inside SAVE_DATA)

# Your runtime game memory
var SAVE_DATA: Dictionary = {
	"1": {},
	"2": {},
	"3": {}
}

func _ready() -> void:
	load_settings()
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta:float) -> void:
	if game_timer_active and SAVE_DATA.has(current_slot):
		if not SAVE_DATA[current_slot].has("game_time"):
			SAVE_DATA[current_slot]["game_time"] = 0.0
		
		SAVE_DATA[current_slot]["game_time"] += delta


func register_room_visited(room_name:String) -> void:
	if not game_timer_active or not SAVE_DATA.has(current_slot):
		return
		
	if not SAVE_DATA[current_slot].has("visited_rooms"):
		SAVE_DATA[current_slot]["visited_rooms"] = []
	
	var visited_list: Array = SAVE_DATA[current_slot]["visited_rooms"]
	
	if not visited_list.has(room_name):
		visited_list.append(room_name)
		SAVE_DATA[current_slot]["visited_rooms"] = visited_list
		print_rich("[color=orange]MAP SYSTEM: Discovered new room: %s[/color]" % room_name)
		
		# Update the dictionary percentage value live whenever a new room is registered
		_update_runtime_percentage(current_slot)

## Private helper that calculates and saves the integer percentage directly into the slot dict
func _update_runtime_percentage(slot_id: String) -> void:
	if not SAVE_DATA.has(slot_id) or not SAVE_DATA[slot_id].has("visited_rooms"):
		SAVE_DATA[slot_id]["percent_complete"] = 0
		return
		
	var visited_room_count: float = float(SAVE_DATA[slot_id]["visited_rooms"].size())
	var percentage = (visited_room_count / TOTAL_ROOMS) * 100.0
	
	# Keep it right here inside your primary dictionary state!
	SAVE_DATA[slot_id]["percent_complete"] = int(clamp(percentage, 0.0, 100.0))

## Formats both total play time and map completion percentage into a clean, combined string layout
func get_game_time_rooms_visited_as_string(slot_id: String = current_slot) -> String:
	if not SAVE_DATA.has(slot_id):
		return "00h 00m 00s | 0%"
		
	var total_seconds: int = int(SAVE_DATA[slot_id].get("game_time", 0.0))
	var hours: int = total_seconds / 3600
	var minutes: int = (total_seconds % 3600) / 60
	var seconds: int = total_seconds % 60
	
	var time_string = "%02dh %02dm %02ds" % [hours, minutes, seconds]
	
	# We just pull directly from the dictionary value now instead of running math again!
	var map_percent: int = SAVE_DATA[slot_id].get("percent_complete", 0)
		
	return "%s | %d%%" % [time_string, map_percent]
		
# --- SETTINGS MANAGEMENT ---

func update_setting(key: String, value) -> void:
	if SETTINGS_DATA.has(key):
		SETTINGS_DATA[key] = value
		save_settings()
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
		return
		
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var parsed_data = JSON.parse_string(json_string)
		if parsed_data is Dictionary:
			for key in parsed_data:
				if SETTINGS_DATA.has(key):
					SETTINGS_DATA[key] = parsed_data[key]
			print_rich("[color=cyan]SAVE SYSTEM: Settings loaded from disk.[/color]")
		file.close()

# --- SAVE SLOT MANAGEMENT ---

func _get_save_path(slot_id: String) -> String:
	return "user://save_slot_%s.json" % slot_id

func save_at_station(room_name: String) -> void:
	if not SAVE_DATA.has(current_slot):
		SAVE_DATA[current_slot] = {}
	
	var current_time = SAVE_DATA[current_slot].get("game_time", 0.0)
	var visited_room_list = SAVE_DATA[current_slot].get("visited_rooms", [room_name])
		
	SAVE_DATA[current_slot]["player_data"] = {
		"room_id": room_name,
		"health": 5, 
		"max_health": 5,
		"energy": 5
	}
	SAVE_DATA[current_slot]["game_time"] = current_time
	SAVE_DATA[current_slot]["visited_rooms"] = visited_room_list
	
	# Make sure the dictionary contains the correct value before writing
	_update_runtime_percentage(current_slot)
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

## Write data if the current world/game session is closed i.e. return to menu
func close_session() -> void:
	if game_timer_active:
		save_to_disk()
		game_timer_active = false

## Mobile OS safe guard. Saves state to disk instantly if app backgrounded/swiped away
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if game_timer_active:
			save_to_disk()
