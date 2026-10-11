extends Control

# Target physical swipe distance in centimeters (e.g., 2.5 cm of finger movement)
@export var swipe_distance_cm: float = 0.5
@export var max_swipe_time: float = 0.2

var start_pos: Vector2
var is_tracking: bool = false

func _input(event: InputEvent) -> void:
	# Early return if touch controller is not in use and hidden
	if not owner.visible:
		is_tracking = false
		return
		
	# Start tracking on initial touch
	if event is InputEventScreenTouch and event.pressed:
		start_pos = event.position
		is_tracking = true
		
		# Use scene tree timer for consistency
		var timer = get_tree().create_timer(max_swipe_time)
		timer.timeout.connect(func(): is_tracking = false)

	# Check for swipe during drag
	elif event is InputEventScreenDrag and is_tracking:
		var swipe_vector = event.position - start_pos
		
		# Calculate dynamic threshold based on physical screen DPI
		var dpi = DisplayServer.screen_get_dpi()
		if dpi <= 0:
			dpi = 160.0 # Fallback baseline if DPI cannot be fetched
			
		# Convert centimeters to inches (2.54 cm per inch), then to pixels
		var required_pixel_distance = (swipe_distance_cm / 2.54) * dpi
		
		# Check distance and ensure it is primarily a vertical swipe
		if swipe_vector.length() >= required_pixel_distance and abs(swipe_vector.y) > abs(swipe_vector.x) * 2:
			
			# Stop tracking to prevent repeated triggers during the same drag
			is_tracking = false 
			
			if swipe_vector.y > 0:
				SignalBus.swipe_down_detected.emit()
			else:
				SignalBus.swipe_up_detected.emit()

	# Stop tracking if touch is released
	elif event is InputEventScreenTouch and not event.pressed:
		is_tracking = false
