extends Node

# ==============================================================================
#                               SFX REGISTRY
# ==============================================================================

const SFX = {
	#"player_jump":      preload("res://audio/sfx/player/jump.wav"),
	#"player_hurt":      preload("res://audio/sfx/player/hurt.wav"),
	#"sword_swing":      preload("res://audio/sfx/combat/swing.wav"),
	#"enemy_die":        preload("res://audio/sfx/enemies/impact.wav"),
	#"ui_hover":         preload("res://audio/sfx/ui/click_soft.wav"),
	#"ui_select":        preload("res://audio/sfx/ui/click_hard.wav"),
}

# ==============================================================================
#                               VARIABLES
# ==============================================================================
var music_player: AudioStreamPlayer
var active_bgm_path: String = ""
var stream_cache: Dictionary = {}
var fade_tween: Tween

# SFX Player pool settings
@export var pool_size: int = 8
var sfx_pool: Array[AudioStreamPlayer] = []

# ==============================================================================
#                               INITIALIZATION
# ==============================================================================
func _ready() -> void:
	# Set process mode so it plays even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music" # Route it to music bus!
	music_player.set("parameters/looping", true)
	add_child(music_player)
	music_player.volume_db = linear_to_db(0.0)
	
	# Dynamically instantiate and register the SFX player pool
	for i in range(pool_size):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"  # Directs these players to the SFX bus automatically
		add_child(player)
		sfx_pool.append(player)
	
	# Load in saved bus volume data
	_initialize_saved_volumes()
	
	# Preload all music tracks
	_preload_music()
	
func _preload_music() -> void:
	for zone_key in MapData.ZONE_REGISTRY:
		var zone_data = MapData.ZONE_REGISTRY[zone_key]
		var path = zone_data.get("bgm","")
		
		if path != "" and not stream_cache.has(path):
			stream_cache[path] = load(path)
	
	# Cache extra music not related to each zone here for titles, cinmetaics etc.
	_add_music_to_cache("res://states/title_state/title_theme.mp3")

func _add_music_to_cache(path:String) -> void:
	if not stream_cache.has(path):
		stream_cache[path] = load(path)

func _initialize_saved_volumes() -> void:
	# Loop through your physical bus names directly
	for bus_name in ["Master", "Music", "SFX"]:
		# Dynamically build the exact key (e.g. "Music Volume")
		var key = bus_name + " Volume"
		var value: float = SaveManager.SETTINGS_DATA.get(key, 1.0)
		
		# Apply directly to Godot's hardware Audio Server
		var bus_index = AudioServer.get_bus_index(bus_name)
		if bus_index != -1:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
			AudioServer.set_bus_mute(bus_index, value <= 0.0)

# ==============================================================================
#                           MUSIC MANAGEMENT (FADES)
# ==============================================================================

## Fades out and kills current music to prepare for a clean start
func stop_music(fade_time: float = 1.0) -> void:
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", -60.0, fade_time)
	fade_tween.tween_callback(music_player.stop)

func start_music(bgm_path: String, fade_time: float = 2.0) -> void:
	# Don't interrupt if we are already playing this track
	if active_bgm_path == bgm_path:
		return
	active_bgm_path = bgm_path
	
	# Kill current transition
	if fade_tween: fade_tween.kill()
	fade_tween = create_tween()
	
	# If playing, fade out the current volume
	if music_player.playing:
		fade_tween.tween_property(music_player, "volume_db", -60.0, fade_time)
	else:
		music_player.volume_db = -60.0
	
	# Swap the music stream
	fade_tween.tween_callback(func():
		if bgm_path == "":
			music_player.stop()
		else:
			music_player.stream = stream_cache.get(bgm_path)
			music_player.play()
			
	)
	
	# Fade in the new volume
	fade_tween.tween_property(music_player, "volume_db", 0.0, fade_time)

# ==============================================================================
#                             SFX POOL MANAGEMENT
# ==============================================================================

## Finds an available SFX player from our pool that is not currently playing anything
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	# Fallback: If all are playing, override the oldest/first player
	return sfx_pool[0]

## Plays sound by its key name
## Determine how many loops
## Adds 10% pitch_variance
func play_sfx(sfx_key: String, loops: int = 1, pitch_variance: float = 0.0) -> void:
	if not SFX.has(sfx_key):
		push_error("AudioManager: SFX key '" + sfx_key + "' does not exist in the SFX dictionary!")
		return
		
	var stream = SFX[sfx_key]
	var player = _get_available_sfx_player()
	
	# Pitch randomization "juice"
	if pitch_variance > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	else:
		player.pitch_scale = 1.0
		
	_play_sfx_loop_helper(player, stream, loops)

# Helper to handle loop counts dynamically
func _play_sfx_loop_helper(player: AudioStreamPlayer, stream: AudioStream, loops_left: int) -> void:
	if loops_left <= 0:
		return
		
	player.stream = stream
	player.play()
	
	await player.finished
	
	# Check if player wasn't hijacked by a different SFX during the wait
	if player.stream == stream:
		_play_sfx_loop_helper(player, stream, loops_left - 1)
