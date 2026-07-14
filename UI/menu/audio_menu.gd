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
	volume_changed.emit(bus_name, value)

func _clear_focus(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			child.focus_mode = Control.FOCUS_NONE
			_clear_focus(child) # Recursive cleanup
