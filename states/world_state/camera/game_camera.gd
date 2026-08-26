extends Camera2D

@export var x_offset_distance: float = 6.0
@export var look_down_modifier: float = 0.12 # percentage of y velocity
@export var follow_smoothing_speed: float = 12.0
@export var pan_smoothing_speed: float = 2.0

var shake_tween: Tween
var zoom_tween: Tween

var overridden = false

var locked_position: Vector2 = Vector2.ZERO
var followed_target: Node2D = null
var lock_x: bool = true
var lock_y: bool = true

func _ready() -> void:
	SignalBus.screenshake_requested.connect(shake)
	SignalBus.stop_screenshake.connect(stop_shake)
	SignalBus.camera_override_requested.connect(set_override)
	SignalBus.camera_override_cleared.connect(clear_override)
	SignalBus.camera_zoom_requested.connect(zoom_pulse)
	
	position_smoothing_enabled = true
	position_smoothing_speed = follow_smoothing_speed

func snap_to_target(node: Node2D = null) -> void:
	global_position = node.global_position
	reset_smoothing()

func set_room_limits(room_node: Node2D) -> void:
	var limits = room_node.get_node("CameraLimits")

	var rect_pos = limits.global_position
	var rect_size = limits.size
	
	limit_left = int(rect_pos.x)
	limit_top = int(rect_pos.y)
	limit_right = int(rect_pos.x + rect_size.x)
	limit_bottom = int(rect_pos.y + rect_size.y)

func clamp_position(raw_target: Vector2) -> Vector2:
	# Get half of the viewport size, scaled down by current camera zoom
	var viewport_half = get_viewport_rect().size * 0.5 / zoom
	
	return Vector2(
		clamp(raw_target.x, limit_left + viewport_half.x, limit_right - viewport_half.x),
		clamp(raw_target.y, limit_top + viewport_half.y, limit_bottom - viewport_half.y)
	)

func update_target(player: CharacterBody2D, delta: float) -> void:
	var desired_pos = global_position
	
	if not overridden:
		desired_pos = player.global_position
		desired_pos.x += player.move_component.facing * x_offset_distance
		# Push look down based on a percentage of player's fall speed for smoothness
		if player.velocity.y > 0:
			desired_pos.y += player.velocity.y * look_down_modifier

		position_smoothing_speed = follow_smoothing_speed
	else:
		var target_pos = locked_position
		if followed_target and is_instance_valid(followed_target):
			target_pos = followed_target.global_position
		
		if lock_y: 
			desired_pos.x = target_pos.x
		if lock_x:
			desired_pos.y = target_pos.y

		position_smoothing_speed = pan_smoothing_speed

	var smoothed_pos = global_position.lerp(desired_pos, position_smoothing_speed * delta)
	global_position = clamp_position(smoothed_pos)

func set_override(pos: Vector2, x: bool = true, y: bool = true, follow: Node2D = null) -> void:

	locked_position = pos
	followed_target = follow
	lock_x = x
	lock_y = y
	overridden = true

func clear_override() -> void:
	followed_target = null
	overridden = false

func shake(max_x: float, max_y: float, duration: float) -> void:
	if not SaveManager.SETTINGS_DATA.get("Screenshake", true):
		return
	if shake_tween:
		shake_tween.kill()
		
	shake_tween = create_tween()
	var shake_speed: float = 0.05 
	var loops: int = int(duration / shake_speed)
	
	for i in range(loops):
		var t: float = float(i) / float(loops)
		var current_decay: float = 1.0 - t
		var target_offset = Vector2(
			randf_range(-max_x, max_x) * current_decay,
			randf_range(-max_y, max_y) * current_decay
		)
		shake_tween.tween_property(self, "offset", target_offset, shake_speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
			
	shake_tween.tween_property(self, "offset", Vector2.ZERO, shake_speed)

func stop_shake() -> void:
	if shake_tween:
		shake_tween.kill()
	shake_tween = create_tween()
	shake_tween.tween_property(self, "offset", Vector2.ZERO, 0.05)

func zoom_pulse(zoom_multiplier: float, duration: float) -> void:
	if zoom_tween:
		zoom_tween.kill()
		
	zoom_tween = create_tween()
	var base_zoom = zoom
	var target_zoom = base_zoom * zoom_multiplier
	
	zoom_tween.tween_property(self, "zoom", target_zoom, duration * 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	zoom_tween.tween_property(self, "zoom", base_zoom, duration * 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
