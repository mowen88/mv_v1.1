extends VBoxContainer

signal back_requested

func _ready() -> void:
	# Scans the menu and creates all relevant signals
	_connect_menu_signals(self)

# Loop through and add the signals
func _connect_menu_signals(node: Node) -> void:
	for child in node.get_children():
		# Remove focus mode for touch screen cleanliness
		if child is Control:
			child.focus_mode = Control.FOCUS_NONE
		
		# Connect Sliders
		if child is Slider:
			child.value_changed.connect(_on_slider_changed.bind(child.name))
			
		# Connect buttons
		elif child is Button:
			child.pressed.connect(_on_button_pressed.bind(child.name))
			
		## If this child contains sub-nodes (like HBoxContainer), scan inside it too!
		#if child.get_child_count() > 0:
			#_connect_menu_signals(child)

# Button handling
func _on_button_pressed(button_name: String) -> void:
	match button_name:
		"BackButton":
			back_requested.emit()
			
# 0 to 100 slider handling
func _on_slider_changed(value: float, slider_name: String) -> void:
	match slider_name:
		"MusicSlider":
			print("[SETTINGS] Music Volume: ", value, "%")
			# Link this directly to your AudioManager sound bus later!
			
		"SFXSlider":
			print("[SETTINGS] SFX Volume: ", value, "%")
			# Link this directly to your AudioManager sound bus later!
