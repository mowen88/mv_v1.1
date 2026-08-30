extends Node

# --- SETTINGS CONFIGURATION ---

# Device path to save data to
const SETTINGS_PATH = "user://settings.json"
# Total room count var not const due to .size() being runtime function not compile time
#var TOTAL_ROOMS: float = 5#MapData.ROOM_REGISTRY.size()

var TOTAL_ROOMS: int:
	get:
		var room_count = 0
		for room_list in MapData.ROOM_REGISTRY.values():
			room_count += room_list.size()
		return room_count

var SETTINGS_DATA: Dictionary = {
	"Master Volume": 1.0,
	"Music Volume": 1.0,
	"SFX Volume": 1.0,
	"Battery Saver": true,
	"Screenshake": true,
	"Vibration": true,
	"Language": "English"
}

## Debug override start room for testing
#var debug_override_room: PackedScene = preload("res://states/world_state/rooms/01_a/01_a.tscn")
var debug_override_room: PackedScene = null# preload("res://states/world_state/rooms/a_01.tscn")

# --- SAVE SLOT CONFIGURATION ---
var current_slot: String = "1"
var game_timer_active: bool = false

# Track the sessions visited rooms (only commited to disk when saving at station)
var session_visited_rooms: Array = []

# Runtime game memory
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

## Add unique ability to save slot
func add_ability(ability_name: String) -> void:

	if not SAVE_DATA[current_slot].has("abilities"):
		SAVE_DATA[current_slot]["abilities"] = {}
		
	var abilities: Dictionary = SAVE_DATA[current_slot]["abilities"]
	
	if not abilities.has(ability_name):
		abilities[ability_name] = true
		print_rich("[color=cyan]SAVE SYSTEM: Unlocked ability '%s' for Slot %s[/color]" % [ability_name, current_slot])
		save_to_disk()

## Add item to save slot
func add_item(item_name: String) -> void:

	if not SAVE_DATA[current_slot].has("items"):
		SAVE_DATA[current_slot]["items"] = {}
		
	var items: Dictionary = SAVE_DATA[current_slot]["items"]
	
	# Add to current dictionary, default to 0 if not exists so adds 1
	items[item_name] = items.get(item_name, 0) + 1
		
	print_rich("[color=cyan]SAVE SYSTEM: Collected item '%s' for Slot %s[/color]" % [item_name, current_slot])
	save_to_disk()
		
## Helper that calculates and saves the integer percentage directly into the slot dict
func _update_game_completion_percentage(slot_id: String) -> void:
	if not SAVE_DATA.has(slot_id) or not SAVE_DATA[slot_id].has("visited_rooms"):
		SAVE_DATA[slot_id]["percent_complete"] = 0
		return
		
	var visited_room_count: float = float(SAVE_DATA[slot_id]["visited_rooms"].size())
	var percentage = (visited_room_count / TOTAL_ROOMS) * 100.0
	
	# Keep it right here inside primary dictionary state
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
	
	# Pull directly from the dictionary value now instead of running math again!
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

## Universal tracker for any persistent entity (secret walls, bosses, special items)
func save_persistent_object(object_id: String) -> void:
	if not SAVE_DATA.has(current_slot):
		return
		
	if not SAVE_DATA[current_slot].has("persistent_objects"):
		SAVE_DATA[current_slot]["persistent_objects"] = []
		
	var persistent_list: Array = SAVE_DATA[current_slot]["persistent_objects"]
	if not persistent_list.has(object_id):
		persistent_list.append(object_id)
		SAVE_DATA[current_slot]["persistent_objects"] = persistent_list
		print_rich("[color=yellow]SAVE SYSTEM: Registered persistent object %s[/color]" % object_id)
		save_to_disk()
	else:
		print_rich("[color=red]SAVE SYSTEM: Persistent object already registered %s[/color]" % object_id)

func save_at_station(room_name: String, player: CharacterBody2D) -> void:
	if not SAVE_DATA.has(current_slot):
		SAVE_DATA[current_slot] = {}
	
	# Save the current room ID so the game knows where to reload you!
	SAVE_DATA[current_slot]["room_id"] = room_name.to_lower()
	
	var current_time = SAVE_DATA[current_slot].get("game_time", 0.0)
	var permanent_visited = SAVE_DATA[current_slot].get("visited_rooms", [room_name])
	
	# Merge newly discovered session rooms into the permanent list
	for room in player.session_visited_rooms:
		if not permanent_visited.has(room):
			permanent_visited.append(room)
	
	# Clear the player's session rooms as they're now commited to save
	player.session_visited_rooms.clear()
			
	var existing_banked_coins = SAVE_DATA[current_slot].get("coins", player.banked_coins)
	var new_banked_total = existing_banked_coins + player.current_coins
	
	player.banked_coins = new_banked_total
	player.current_coins = 0
	
	# 3. Commit everything to the slot and write to disk
	SAVE_DATA[current_slot]["room_id"] = room_name
	SAVE_DATA[current_slot]["spawn_id"] = 0
	SAVE_DATA[current_slot]["health"] = player.health_component.max_health
	SAVE_DATA[current_slot]["max_health"] = player.health_component.max_health
	SAVE_DATA[current_slot]["energy"] = player.energy_component.current_energy
	SAVE_DATA[current_slot]["coins"] = new_banked_total
	SAVE_DATA[current_slot]["game_time"] = current_time
	SAVE_DATA[current_slot]["visited_rooms"] = permanent_visited
	
	_update_game_completion_percentage(current_slot)
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

func get_saved_room() -> PackedScene:
	if debug_override_room != null:
		return debug_override_room
		
	var room_name: String = "a_01"
	
	if SAVE_DATA.has(current_slot) and SAVE_DATA[current_slot].has("room_id"):
		room_name = SAVE_DATA[current_slot]["room_id"]
		
	# Ensure the path components are lowercased to match Android's case-sensitive file system
	var clean_name = room_name.to_lower()
	var room_path: String = "res://states/world_state/rooms/%s.tscn" % [clean_name]
	
	if ResourceLoader.exists(room_path):
		var loaded_scene = load(room_path) as PackedScene
		if loaded_scene:
			return loaded_scene
			
	return preload("res://states/world_state/rooms/a_01.tscn")
#func get_saved_room() -> PackedScene:
	#var room_name: String = "01_a"
	#
	#if SAVE_DATA.has(current_slot) and SAVE_DATA[current_slot].has("player_data"):
		#room_name = SAVE_DATA[current_slot]["player_data"].get("room_id", "01_a")
		#
	#var room_path: String = "res://states/world_state/rooms/%s/%s.tscn" % [room_name, room_name]
	#
	#if FileAccess.file_exists(room_path):
		#var loaded_scene = load(room_path) as PackedScene
		#if loaded_scene:
			#return loaded_scene
			#
	#return preload("res://states/world_state/rooms/01_a/01_a.tscn")

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
