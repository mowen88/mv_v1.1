extends Control

@onready var main_menu: VBoxContainer = $MainMenu
@onready var settings_menu: VBoxContainer = $SettingsMenu
@onready var save_slot_menu: VBoxContainer = $SaveSlotMenu
@onready var pause_menu: VBoxContainer = $PauseMenu

var current_menu: VBoxContainer = null
var fade_speed: float = 0.15

var menu_stack: Array[VBoxContainer] = []

func _ready() -> void:
	# process_mode = PROCESS_MODE_ALWAYS
	
	# Wire up child signals
	main_menu.continue_requested.connect(func(): show_panel(save_slot_menu))
	main_menu.settings_requested.connect(func(): show_panel(settings_menu))
	
	pause_menu.settings_requested.connect(func(): show_panel(settings_menu))
	
	pause_menu.quit_requested.connect(_quit_to_tile)
	settings_menu.back_requested.connect(_go_back)
	save_slot_menu.back_requested.connect(_go_back)
	
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
