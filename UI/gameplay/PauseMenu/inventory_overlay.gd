extends CanvasLayer

signal unpause_requested

@export var tab_switch_sound: AudioStream

@onready var tab_header_bar: HBoxContainer = $Control/VBoxContainer/TabHeaderBar
@onready var content_container: Control = $Control/VBoxContainer/TabContentContainer
@onready var menu_manager: Control = $Control/VBoxContainer/TabContentContainer/SystemPanel/MenuAnchor/MenuManager
@onready var tab_underline: Control = $Control/VBoxContainer/TabHeaderBar/TabUnderline
@onready var close_button: TextureButton = $CloseButton

@onready var quest_scene: Control = $Control/VBoxContainer/TabContentContainer/QuestsPanel/QuestsScene
@onready var map_scene: Control = $Control/VBoxContainer/TabContentContainer/MapPanel/MapScene

var tabs: Array[Control] = []
var active_tween: Tween

# Remember the last opened tab across pauses (default to System, which is index 3)
static var last_tab_index: int = 3

func _ready() -> void:
	# Connect unpause signal to close button
	close_button.pressed.connect(func(): unpause_requested.emit())
	
	# Gather all tab control children from the content container
	for child in content_container.get_children():
		if child is Control:
			tabs.append(child)
	
	# Connect the header buttons and make them flat by default
	var buttons = tab_header_bar.get_children()
	for i in range(buttons.size()):
		if buttons[i] is Button:
			buttons[i].pressed.connect(_on_tab_button_pressed.bind(i))
			buttons[i].flat = true
			
	# Initialize the menu manager ONCE right here when the overlay loads
	if menu_manager:
		menu_manager._initialize_menu("PauseMenu")

func open_inventory() -> void:
	
	# Update hte quest UI on opening
	quest_scene.update_current_details()
	
	# Update map UI on opening AND pass references
	var world_state = get_parent()
	var room_name = world_state.current_room_node.name
	var player_node = world_state.player
	map_scene.update_map_display(room_name, player_node)
	
	# Instantly show the remembered tab
	for i in range(tabs.size()):
		if i == last_tab_index:
			tabs[i].visible = true
			tabs[i].modulate.a = 1.0
		else:
			tabs[i].visible = false
			tabs[i].modulate.a = 0.0
			
	# Wait one frame for the HBoxContainer to calculate positions, then snap
	_snap_underline_deferred(last_tab_index)

func _snap_underline_deferred(tab_index: int) -> void:
	await get_tree().process_frame
	if not tab_underline:
		return
		
	var target_button = tab_header_bar.get_child(tab_index) as Button
	if target_button:
		var underline_height = 3.0
		tab_underline.position.x = target_button.position.x
		tab_underline.size.x = target_button.size.x
		tab_underline.size.y = underline_height
		tab_underline.position.y = target_button.position.y + target_button.size.y - underline_height

func switch_tab(new_index: int) -> void:
	if new_index == last_tab_index:
		return
		
	var old_tab = tabs[last_tab_index]
	var new_tab = tabs[new_index]
	
	# Grab the target button directly using the index
	var target_button = tab_header_bar.get_child(new_index) as Button
			
	last_tab_index = new_index
	
	# Play sound
	AudioManager.play_sfx(tab_switch_sound)
	
	# Kill any active transition so they don't stutter
	if active_tween and active_tween.is_running():
		active_tween.kill()
		
	active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Fade out old tab content / fade in new tab 
	active_tween.tween_property(old_tab, "modulate:a", 0.0, 0.15)
	new_tab.visible = true
	new_tab.modulate.a = 0.0
	active_tween.tween_property(new_tab, "modulate:a", 1.0, 0.15)
	active_tween.chain().tween_callback(func(): old_tab.visible = false)
	
	# Animate the underline to slide, resize width, and align to the bottom of the button
	if target_button and tab_underline:
		var underline_height = 3.0
		var target_x = target_button.position.x
		var target_y = target_button.position.y + target_button.size.y - underline_height
		var target_width = target_button.size.x
		
		active_tween.tween_property(tab_underline, "position:x", target_x, 0.2)
		active_tween.tween_property(tab_underline, "position:y", target_y, 0.2)
		active_tween.tween_property(tab_underline, "size:x", target_width, 0.2)
		active_tween.tween_property(tab_underline, "size:y", underline_height, 0.2)

func _on_tab_button_pressed(new_index: int) -> void:
	if new_index == last_tab_index:
		return
	
	switch_tab(new_index)
