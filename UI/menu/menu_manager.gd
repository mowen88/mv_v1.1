extends Control

@onready var main_menu: VBoxContainer = $MainMenu
@onready var settings_menu: VBoxContainer = $SettingsMenu
@onready var audio_menu: VBoxContainer = $AudioMenu
@onready var gameplay_menu: VBoxContainer = $GameplayMenu
@onready var save_slot_menu: VBoxContainer = $SaveSlotMenu
@onready var pause_menu: VBoxContainer = $PauseMenu
@onready var confirm_delete_menu: VBoxContainer = $ConfirmDeleteMenu

var pending_delete_slot: String = ""

var current_menu: VBoxContainer = null
var fade_speed: float = 0.15

var menu_stack: Array[VBoxContainer] = []

func _ready() -> void:
	# process_mode = PROCESS_MODE_ALWAYS
	audio_menu.volume_changed.connect(_on_volume_changed)
	
	# Wire up child signals
	main_menu.start_game_requested.connect(func(): show_panel(save_slot_menu))
	main_menu.settings_requested.connect(func(): show_panel(settings_menu))
	pause_menu.settings_requested.connect(func(): show_panel(settings_menu))
	settings_menu.audio_requested.connect(func(): show_panel(audio_menu))
	settings_menu.gameplay_requested.connect(func(): show_panel(gameplay_menu))
	
	gameplay_menu.screenshake_toggle_requested.connect(_on_screenshake_toggled)
	gameplay_menu.vibrate_toggle_requested.connect(_on_vibrate_toggled)
	gameplay_menu.battery_saver_toggle_requested.connect(_on_battery_saver_toggled)

	pause_menu.quit_requested.connect(_quit_to_tile)
	audio_menu.back_requested.connect(_go_back)
	gameplay_menu.back_requested.connect(_go_back)
	save_slot_menu.back_requested.connect(_go_back)
	save_slot_menu.slot_requested.connect(_on_save_slot_selected)
	save_slot_menu.delete_requested.connect(_on_delete_requested)
	confirm_delete_menu.confirm.connect(_on_delete_confirmed)
	confirm_delete_menu.cancel.connect(_go_back)

func _on_volume_changed(bus_name:String, value:float) -> void:
	var key = bus_name + " Volume"
	SaveManager.update_setting(key, value)
	print(key, value)
	## 2. Update the AudioServer
	## Make sure your Audio Bus is named exactly "Music", "SFX", or "Master"
	#var bus_idx = AudioServer.get_bus_index(bus_name)
	#
	#if bus_idx != -1:
		#AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	#else:
		#push_warning("Audio Bus not found: " + bus_name)
		
func _on_battery_saver_toggled(is_on: bool) -> void:
	Input.vibrate_handheld(200)
	SaveManager.update_setting("Battery Saver", is_on)
	Engine.max_fps = 30 if is_on else 60

func _on_vibrate_toggled(is_on: bool) -> void:
	Input.vibrate_handheld(200)
	SaveManager.update_setting("Vibration", is_on)

func _on_screenshake_toggled(is_on: bool) -> void:
	Input.vibrate_handheld(200)
	SaveManager.update_setting("Screenshake", is_on)

func _initialize_menu(menu_name: String = "MainMenu") -> void:
	
	menu_stack.clear()
	# Look up the child node using the string name
	current_menu = get_node_or_null(menu_name)	
	current_menu.modulate.a = 0.0
	current_menu.visible = true

	var fade_in = create_tween()
	fade_in.tween_property(current_menu, "modulate:a", 1.0, fade_speed)

func show_panel(target_menu: VBoxContainer) -> void:
	if InputManager.input_lock:
		return
		
	InputManager.input_lock = true
	
	# Fade out current active menu panel
	if current_menu and current_menu.visible:
		menu_stack.append(current_menu)
		
		var fade_out = create_tween()
		fade_out.tween_property(current_menu, "modulate:a", 0.0, fade_speed)
		await fade_out.finished
		current_menu.visible = false
		
	# Setup and fade in target menu panel
	current_menu = target_menu
	current_menu.modulate.a = 0.0
	current_menu.visible = true
	
	var fade_in = create_tween()
	fade_in.tween_property(current_menu, "modulate:a", 1.0, fade_speed)
	await fade_in.finished
	
	InputManager.input_lock = false

func _on_delete_requested(slot_id: String) -> void:
	pending_delete_slot = slot_id
	show_panel(confirm_delete_menu)

func _on_delete_confirmed() -> void:
	SaveManager.delete_slot(pending_delete_slot)
	_go_back()

func _on_save_slot_selected(slot_id: String) -> void:
	SaveManager.current_slot = slot_id
	
	var save_exists: bool = SaveManager.load_from_disk(slot_id)
	
	if not save_exists:
		SaveManager.SAVE_DATA[slot_id] = {
			"enemies_dead": [],
			"player_data": {
				"room_id": "01_a", # Fresh starting room
				"health": 5,
				"max_health": 5,
				"energy": 5
			}
		}
		
		SaveManager.save_to_disk()
		
	StateManager.change_state(StateManager.GameState.WORLD, 0.5, 1.0, "fade", "blinds")

func _go_back() -> void:
	# If there is nothing left in our history stack, we can't go back further
	if menu_stack.is_empty() or InputManager.input_lock:
		return
		
	InputManager.input_lock = true
	
	# Fade out the current layout panel
	if current_menu and current_menu.visible:
		var fade_out = create_tween()
		fade_out.tween_property(current_menu, "modulate:a", 0.0, fade_speed)
		await fade_out.finished
		current_menu.visible = false
	
	# Pop the absolute last visited menu layout off the top of our array stack
	current_menu = menu_stack.pop_back()
	# Bring back our previous layout cleanly
	current_menu.modulate.a = 0.0
	current_menu.visible = true
	
	var fade_in = create_tween()
	fade_in.tween_property(current_menu, "modulate:a", 1.0, fade_speed)
	await fade_in.finished
	InputManager.input_lock = false
	
func _quit_to_tile() -> void:
	get_tree().paused = false
	StateManager.change_state(StateManager.GameState.TITLE, 0.5, 1.0, "fade", "blinds")

func _on_slot_deleted(slot_id: String) -> void:
	# Permanently wipe data from RAM and drop the JSON file from disk
	SaveManager.delete_slot(slot_id)
	
	# Run a quick fade blink to visually refresh the menu state instantly
	InputManager.input_lock = true
	var refresh_tween = create_tween()
	refresh_tween.tween_property(save_slot_menu, "modulate:a", 0.0, fade_speed)
	refresh_tween.tween_property(save_slot_menu, "modulate:a", 1.0, fade_speed)
	await refresh_tween.finished
	InputManager.input_lock = false
