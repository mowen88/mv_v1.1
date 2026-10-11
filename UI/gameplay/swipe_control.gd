extends Control

@export var swipe_distance_cm: float = 0.4
@export var max_swipe_time: float = 0.15 # Maximum time allowed to complete the swipe

var active_touch_index: int = -1
var start_pos: Vector2 = Vector2.ZERO
var required_pixel_distance: float = 0.0
var is_timed_out: bool = false

func _ready() -> void:
	var dpi = DisplayServer.screen_get_dpi()
	if dpi <= 0:
		dpi = 160.0
	required_pixel_distance = (swipe_distance_cm / 2.54) * dpi

func _input(event: InputEvent) -> void:
	if not owner.visible:
		active_touch_index = -1
		return
		
	# 1. When touch begins, start tracking and kick off a timer window
	if event is InputEventScreenTouch and event.pressed:
		active_touch_index = event.index
		start_pos = event.position
		is_timed_out = false
		
		# Start a timer; if it expires before a swipe happens, disable this touch
		var timer = get_tree().create_timer(max_swipe_time)
		timer.timeout.connect(func():
			if active_touch_index == event.index:
				is_timed_out = true
		)

	# 2. Track drag only if time hasn't run out
	elif event is InputEventScreenDrag and event.index == active_touch_index:
		if is_timed_out:
			return
			
		var swipe_vector = event.position - start_pos
		
		# Check physical distance and vertical bias
		if swipe_vector.length() >= required_pixel_distance and abs(swipe_vector.y) > abs(swipe_vector.x) * 2:
			active_touch_index = -1 # Consumed
			
			if swipe_vector.y >= 0:
				SignalBus.swipe_down_detected.emit()
			else:
				SignalBus.swipe_up_detected.emit()

	# 3. Clear tracking when finger lifts
	elif event is InputEventScreenTouch and not event.pressed:
		if event.index == active_touch_index:
			active_touch_index = -1
