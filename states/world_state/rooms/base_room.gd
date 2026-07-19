class_name BaseRoom
extends Node2D

@export_category("Zone Setup")
@export var zone_name: String = ""
@export var show_banner: bool = false

@export_category("Audio Track Settings")
@export var room_music_track: AudioStream

@export_category("Boss Mechanics")
@export var boss_room: bool = false
@export var boss_id: String = ""
@export var boss_music_track: AudioStream

func _ready() -> void:
	# Triggers automatically the moment world_state adds this room node to the tree
	initialize_room_configurations()

## Evaluates the inspector variables to crossfade tracks and signal the UI layer
func initialize_room_configurations() -> void:
	# --- 1. HANDLE REGIONAL UI BANNER TRIGGERS ---
	SignalBus.zone_banner_requested.emit(zone_name, show_banner)
		
	# --- 2. EVALUATE DYNAMIC AUDIO TRACK ASSIGNMENT ---
	var target_track: AudioStream = room_music_track

	if boss_room and boss_id != "":
		# Safely access active slot RAM save dictionary
		var defeated_list: Array = SaveManager.SAVE_DATA[SaveManager.current_slot].get("defeated_bosses", [])
		
		if defeated_list.has(boss_id):
			print_rich("[color=yellow]AUDIO SYSTEM: Boss '%s' is already dead. Using standard loop.[/color]" % boss_id)
			target_track = room_music_track
		else:
			print_rich("[color=red]AUDIO SYSTEM: Boss '%s' is alive! Playing boss theme.[/color]" % boss_id)
			target_track = boss_music_track

	# --- 3. TRANSITION AUDIO TRACK ---
	if target_track:
		AudioManager.change_music(target_track, 0.75, 0.75)
	else:
		AudioManager.stop_music(1.0)
