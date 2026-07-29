extends Camera2D

var shake_tween: Tween

@export var x_offset_distance: float = 100.0
@export var lerp_speed: float = 5.0

var x_offset: float = 0.0
var current_target_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Connect to the global signal bus
	SignalBus.screenshake_requested.connect(shake)

func _process(delta: float) -> void:
	global_position = global_position.lerp(current_target_pos, lerp_speed * delta)
	
func move_camera(current_pos: Vector2, target_pos: Vector2, speed: float, delta: float) -> Vector2:
	return current_pos.lerp(target_pos, speed * delta)

## Triggers a screenshake using max X and Y pixel boundaries over a set duration
func shake(max_x: float, max_y: float, duration: float) -> void:
	if not SaveManager.SETTINGS_DATA.get("Screenshake", true):
		return
		
	if shake_tween:
		shake_tween.kill()
		
	shake_tween = create_tween()
	
	# Determine how fast the camera shakes
	var shake_speed: float = 0.05 
	var loops: int = int(duration / shake_speed)
	
	for i in range(loops):
		# Calculate decay
		var t: float = float(i) / float(loops)
		var current_decay: float = 1.0 - t
		
		# Generate a random target offset within our boundary limits
		var target_offset = Vector2(
			randf_range(-max_x, max_x) * current_decay,
			randf_range(-max_y, max_y) * current_decay
		)
		
		# Snap back or move rapidly to the new offset position
		shake_tween.tween_property(self, "offset", target_offset, shake_speed)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
			
	# Final step: Always guarantee the camera perfectly centers itself back
	shake_tween.tween_property(self, "offset", Vector2.ZERO, shake_speed)
