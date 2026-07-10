extends Control

# Percentage of screen height (0.08 = 8% of screen height)
@export var swipe_threshold_percent: float = 0.1
@export var max_swipe_time: float = 0.2

var start_pos: Vector2
var is_tracking: bool = false

func _input(event: InputEvent) -> void:
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
		
		# Calculate dynamic threshold based on current screen height
		var screen_height = get_viewport_rect().size.y
		var dynamic_threshold = screen_height * swipe_threshold_percent
		
		# Check distance and ensure it is primarily a vertical swipe
		if swipe_vector.length() >= dynamic_threshold and swipe_vector.y > abs(swipe_vector.x) * 2:
			Input.action_press("swipe_down")
			Input.action_release("swipe_down")
			
			# Stop tracking to prevent repeated triggers during the same drag
			is_tracking = false 
			print("Swipe Down Triggered!")

	# 3. Stop tracking if touch is released
	elif event is InputEventScreenTouch and not event.pressed:
		is_tracking = false
