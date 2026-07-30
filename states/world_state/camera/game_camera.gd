extends Camera2D

@export var x_offset_distance: float = 4.0
@export var player_lerp_speed: float = 6.0
@export var player_down_lerp_speed: float = 100.0
@export var player_up_lerp_speed: float = 12.0
@export var pan_lerp_speed: float = 4.0

var player_offset: Vector2 = Vector2.ZERO
var current_pos: Vector2 = Vector2.ZERO
var shake_tween: Tween
var zoom_tween: Tween

# 1. Clear, descriptive states
enum CameraState {SNAP, FOLLOW, PAN, RETURNING }
var current_state: CameraState = CameraState.SNAP

var locked_position: Vector2 = Vector2.ZERO
var followed_target: Node2D = null
var lock_x: bool = true
var lock_y: bool = true

func _ready() -> void:
	SignalBus.screenshake_requested.connect(shake)
	SignalBus.camera_override_requested.connect(set_override)
	SignalBus.camera_override_cleared.connect(clear_override)
	SignalBus.camera_zoom_requested.connect(zoom_pulse)

func snap_to_target(node: Node2D = null) -> void:
	current_state = CameraState.SNAP
	# Instantly seed positions to avoid the zero-vector lerp frame bounce
	player_offset = Vector2(node.global_position)
	current_pos = node.global_position
	global_position = current_pos

func update_target(player: CharacterBody2D, delta: float) -> void:
	# Calculate player target info normally
	
	var target_pos = player.global_position
	var target_x_offset = player.move_component.facing * x_offset_distance
	player_offset.x = lerp(player_offset.x, target_x_offset, player_lerp_speed * delta)
	target_pos.x += player_offset.x
	
	# Add faster lerp if going down past the camera
	if player.global_position.y > global_position.y:
		player_offset.y = lerp(player_offset.y, target_pos.y, player_down_lerp_speed  * delta)
	else:
		player_offset.y = lerp(player_offset.y, target_pos.y, player_up_lerp_speed  * delta)
	
	target_pos.y = player_offset.y

	match current_state:

		CameraState.FOLLOW:
			current_pos = target_pos

		CameraState.PAN:
			if followed_target and is_instance_valid(followed_target):
				locked_position = followed_target.global_position
			
			var pan_target = global_position
			if lock_x: pan_target.x = locked_position.x
			if lock_y: pan_target.y = locked_position.y
			current_pos = pan_target

		CameraState.RETURNING:
			# Returning to player smootly and slowly
			current_pos = target_pos
			
			# Snap back to player when close enough
			if global_position.distance_to(current_pos) < 15.0:
				current_state = CameraState.FOLLOW

func set_override(pos: Vector2, x: bool = true, y: bool = true, follow: Node2D = null) -> void:
	locked_position = pos
	followed_target = follow
	lock_x = x
	lock_y = y
	current_state = CameraState.PAN

func clear_override() -> void:
	followed_target = null

	current_state = CameraState.RETURNING

func _process(delta: float) -> void:
	# Clamp target position to room limits so it doesn't lerp to off screen position, making it stop abruptly
	var viewport_half = (get_viewport_rect().size * 0.5) / zoom
	current_pos.x = clamp(current_pos.x, limit_left + viewport_half.x, limit_right - viewport_half.x)
	current_pos.y = clamp(current_pos.y, limit_top + viewport_half.y, limit_bottom - viewport_half.y)
	
	if current_state == CameraState.SNAP:
		global_position = current_pos
		current_state = CameraState.FOLLOW
		return
		
	# Determine speed based entirely on clean states
	var active_speed = player_lerp_speed
	if current_state == CameraState.PAN:
		active_speed = pan_lerp_speed
	elif current_state == CameraState.RETURNING:
		active_speed = pan_lerp_speed # Glides smoothly back to player without popping

	global_position = global_position.lerp(current_pos, active_speed * delta)

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


func zoom_pulse(zoom_multiplier: float, duration: float) -> void:
	if zoom_tween:
		zoom_tween.kill()
		
	zoom_tween = create_tween()
	var base_zoom = zoom
	var target_zoom = base_zoom * zoom_multiplier
	var half_duration = duration * 0.5
	
	# Tween in the zoom
	zoom_tween.tween_property(self, "zoom", target_zoom, half_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
		
	# Tween out to the original zoom
	zoom_tween.tween_property(self, "zoom", base_zoom, half_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
