extends ScrollContainer

var is_dragging = false
var drag_start_mouse_pos := Vector2.ZERO
var drag_start_scroll_pos := Vector2.ZERO

func _ready() -> void:
	var sb = self.get_v_scroll_bar()
	
	# 1. Make the scrollbar thicker (e.g., 12 pixels wide)
	sb.custom_minimum_size.x = 9 
	
	# 2. Create a solid white, square style for the grabber
	var white_bar = StyleBoxFlat.new()
	white_bar.bg_color = Color.WHITE
	white_bar.corner_radius_top_left = 0
	white_bar.corner_radius_top_right = 0
	white_bar.corner_radius_bottom_left = 0
	white_bar.corner_radius_bottom_right = 0
	
	sb.add_theme_stylebox_override("grabber", white_bar)
	sb.add_theme_stylebox_override("grabber_highlight", white_bar)
	sb.add_theme_stylebox_override("grabber_pressed", white_bar)
	
	# 3. Remove the background track completely so only the white bar shows
	sb.add_theme_stylebox_override("scroll", StyleBoxEmpty.new())
	sb.add_theme_stylebox_override("scroll_focus", StyleBoxEmpty.new())

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if is_dragging:
				drag_start_mouse_pos = event.position
				drag_start_scroll_pos = Vector2(scroll_horizontal, scroll_vertical)
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_mouse_pos
		# Invert delta to drag the content naturally
		scroll_vertical = int(drag_start_scroll_pos.y - delta.y)
