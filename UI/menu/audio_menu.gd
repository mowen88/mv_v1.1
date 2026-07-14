extends VBoxContainer

signal back_requested
signal volume_changed(bus_name: String, value: float)

func _ready() -> void:
	# 1. Map your UI nodes to their SaveManager keys
	# This keeps everything in one tidy list
	var settings_map = {
		"Master": $MasterRow/MasterSlider,
		"Music": $MusicRow/MusicSlider,
		"SFX": $SFXRow/SFXSlider
	}
	
	# 2. Set values FIRST
	for bus_name in settings_map:
		var slider = settings_map[bus_name]
		var key = bus_name + " Volume"
		slider.value = SaveManager.SETTINGS_DATA[key]
		
	# 3. Connect signals SECOND (This prevents the "snapping" or "reset" loop)
	for bus_name in settings_map:
		var slider = settings_map[bus_name]
		slider.value_changed.connect(_on_slider_changed.bind(bus_name))
		
	# 4. Handle other buttons
	$BackButton.pressed.connect(func(): back_requested.emit())

func _on_slider_changed(value: float, bus_name: String) -> void:
	# Update SaveManager's dictionary
	var key = bus_name + " Volume"
	SaveManager.SETTINGS_DATA[key] = value
	
	# Apply changes to Godot's Audio Server
	_apply_volume_to_server(bus_name, value)
	
	# (Optional) If your SaveManager writes to disk on change, call it here:
	# SaveManager.save_settings()
	
	volume_changed.emit(bus_name, value)
	
func _apply_volume_to_server(bus_name: String, linear_value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		push_error("AudioMenu: Audio bus '" + bus_name + "' was not found in your Godot project!")
		return
		
	# Convert our linear 0.0 - 1.0 slider value to physical Decibels
	var db_value = linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(bus_index, db_value)
	
	# Mute the bus completely if the slider is dragged all the way to 0
	AudioServer.set_bus_mute(bus_index, linear_value <= 0.0)

func _clear_focus(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.focus_mode = Control.FOCUS_NONE
			_clear_focus(child) # Recursive cleanup
